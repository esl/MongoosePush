defmodule MongoosePushWeb.APIv1NotificationControllerTest do
  alias MongoosePushWeb.Support.ControllersHelper
  use MongoosePushWeb.ConnCase, async: true
  import Mox

  setup :verify_on_exit!

  setup %{conn: conn} do
    new_conn = put_req_header(conn, "content-type", "application/json")
    %{spec: MongoosePushWeb.ApiSpec.spec(), conn: new_conn}
  end

  test "correct Request.SendNotification.FlatNotification schema", %{conn: conn} do
    expect(MongoosePush.Notification.MockImpl, :push, fn _id, _req -> :ok end)

    conn = post(conn, "/v1/notification/666", Jason.encode!(ControllersHelper.flat_request()))
    assert json_response(conn, 200) == nil
  end

  test "Request.SendNotification.FlatNotification schema without required service field", %{
    conn: conn
  } do
    conn =
      post(
        conn,
        "/v1/notification/666",
        Jason.encode!(Map.drop(ControllersHelper.flat_request(), ["service"]))
      )

    assert json_response(conn, 422) == ControllersHelper.missing_field_response("service")
  end

  test "Request.SendNotification.FlatNotification schema without required body field", %{
    conn: conn
  } do
    conn =
      post(
        conn,
        "/v1/notification/666",
        Jason.encode!(Map.drop(ControllersHelper.flat_request(), ["body"]))
      )

    assert json_response(conn, 422) == ControllersHelper.missing_field_response("body")
  end

  test "Request.SendNotification.FlatNotification schema with incorrect badge value", %{
    conn: conn
  } do
    conn =
      post(
        conn,
        "/v1/notification/666",
        Jason.encode!(%{ControllersHelper.flat_request() | "badge" => "seven"})
      )

    assert json_response(conn, 422) ==
             ControllersHelper.invalid_field_response("integer", "string", "badge")
  end

  test "Request.SendNotification.FlatNotification schema with unexpected field", %{conn: conn} do
    conn =
      post(
        conn,
        "/v1/notification/666",
        Jason.encode!(Map.put(ControllersHelper.flat_request(), "field", "peek-a-boo"))
      )

    assert json_response(conn, 422) == ControllersHelper.unexpected_field_response("field")
  end

  # Service.error() errors

  test "invalid request error", %{conn: conn} do
    post_and_assert_error_500(conn, :invalid_request, :BadCollapseId)
  end

  test "internal config error", %{conn: conn} do
    post_and_assert_error_500(conn, :internal_config, :BadMessageId)
  end

  test "auth error", %{conn: conn} do
    post_and_assert_error_500(conn, :auth, :MissingProviderToken)
  end

  test "unregistered error", %{conn: conn} do
    post_and_assert_error_500(conn, :unregistered, :Unregistered)
  end

  test "too many requests error", %{conn: conn} do
    post_and_assert_error_500(conn, :too_many_requests, :TooManyRequests)
  end

  test "unspecified error", %{conn: conn} do
    post_and_assert_error_500(conn, :unspecified, :Unspecified)
  end

  test "service internal error", %{conn: conn} do
    post_and_assert_error_500(conn, :service_internal, :InternalServerError)
  end

  test "payload too large error", %{conn: conn} do
    post_and_assert_error_500(conn, :payload_too_large, :PayloadTooLarge)
  end

  test "unknown error", %{conn: conn} do
    post_and_assert_error_500(conn, :unknown, :Unknown)
  end

  # MongoosePush.error() errors

  test "generic no matching pool error", %{conn: conn} do
    post_and_assert_error_500(conn, :generic, :no_matching_pool)
  end

  test "generic connection lost error", %{conn: conn} do
    post_and_assert_error_500(conn, :generic, :connection_lost)
  end

  test "generic invalid notification error", %{conn: conn} do
    post_and_assert_error_500(conn, :generic, :invalid_notification)
  end

  test "generic unable to connect error", %{conn: conn} do
    device_id = "666"
    request = ControllersHelper.flat_request()

    expect(MongoosePush.Notification.MockImpl, :push, fn _device_id, _request ->
      {:error, {:generic, :unable_to_connect}}
    end)

    conn = post(conn, "/v1/notification/#{device_id}", Jason.encode!(request))

    assert json_response(conn, 503) == %{"details" => "Please try again later"}
  end

  # decoder end-to-end tests

  test "decoder test: all possible fields", %{conn: conn} do
    device_id = "1"
    expected_device_id = "1"

    request = %{
      "service" => "apns",
      "body" => "A message from someone",
      "title" => "Notification title",
      "badge" => 7,
      "click_action" => ".SomeApp.Handler.action",
      "tag" => "info",
      "topic" => "com.someapp",
      "data" => %{
        "custom" => "data fields",
        "some_id" => 345_645_332,
        "nested" => %{"fields" => "allowed"}
      },
      "mode" => "prod"
    }

    expected_request = %{
      alert: %{
        badge: 7,
        body: "A message from someone",
        click_action: ".SomeApp.Handler.action",
        tag: "info",
        title: "Notification title"
      },
      data: %{
        "custom" => "data fields",
        "nested" => %{"fields" => "allowed"},
        "some_id" => 345_645_332
      },
      mode: :prod,
      service: :apns,
      topic: "com.someapp"
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "decoder test: all required fields", %{conn: conn} do
    device_id = "2"
    expected_device_id = "2"

    request = %{
      "service" => "fcm",
      "body" => "A message from someone",
      "title" => "Notification title"
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      service: :fcm
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "decoder test: badge & click fields", %{conn: conn} do
    device_id = "3"
    expected_device_id = "3"

    request = %{
      "service" => "apns",
      "body" => "A message from someone",
      "title" => "Notification title",
      "badge" => 777,
      "click_action" => ".SomeApp.Handler.action"
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title",
        badge: 777,
        click_action: ".SomeApp.Handler.action"
      },
      service: :apns
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "decoder test: tag & topic fields", %{conn: conn} do
    device_id = "4"
    expected_device_id = "4"

    request = %{
      "service" => "fcm",
      "body" => "A message from someone",
      "title" => "Notification title",
      "tag" => "info",
      "topic" => "com.someapp"
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title",
        tag: "info"
      },
      service: :fcm,
      topic: "com.someapp"
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "decoder test: data & mode fields", %{conn: conn} do
    device_id = "5"
    expected_device_id = "5"

    request = %{
      "service" => "apns",
      "body" => "A message from someone",
      "title" => "Notification title",
      "data" => %{"more" => "data"},
      "mode" => "dev"
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      service: :apns,
      mode: :dev,
      data: %{"more" => "data"}
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "decoder test: service :fcm & mode :prod fields", %{conn: conn} do
    device_id = "6"
    expected_device_id = "6"

    request = %{
      "service" => "fcm",
      "body" => "A message from someone",
      "title" => "Notification title",
      "mode" => "prod"
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      service: :fcm,
      mode: :prod
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  defp post_and_assert_error_500(conn, type, reason) do
    device_id = "666"
    request = ControllersHelper.flat_request()

    expect(MongoosePush.Notification.MockImpl, :push, fn _device_id, _request ->
      {:error, {type, reason}}
    end)

    conn = post(conn, "/v1/notification/#{device_id}", Jason.encode!(request))

    assert json_response(conn, 500) == %{"details" => to_string(reason)}
  end

  defp post_and_assert(conn, device_id, expected_device_id, request, expected_request) do
    expect(MongoosePush.Notification.MockImpl, :push, fn device_id, request ->
      assert request == expected_request
      assert device_id == expected_device_id
      :ok
    end)

    post(conn, "/v1/notification/#{device_id}", Jason.encode!(request))
  end
end
