defmodule MongoosePushWeb.APIv2NotificationControllerTest do
  alias MongoosePushWeb.Support.ControllersHelper
  use MongoosePushWeb.ConnCase, async: true
  import Mox

  setup :verify_on_exit!

  setup %{conn: conn} do
    new_conn = put_req_header(conn, "content-type", "application/json")
    %{spec: MongoosePushWeb.ApiSpec.spec(), conn: new_conn}
  end

  test "correct Request.SendNotification.Deep.AlertNotification schema", %{conn: conn} do
    expect(MongoosePush.Notification.MockImpl, :push, fn _id, _req -> :ok end)

    conn = post(conn, "/v2/notification/654321", Jason.encode!(ControllersHelper.alert_request()))
    assert json_response(conn, 200) == nil
  end

  test "Request.SendNotification.Deep.AlertNotification schema without required service field", %{
    conn: conn
  } do
    conn =
      post(
        conn,
        "/v2/notification/654321",
        Jason.encode!(Map.drop(ControllersHelper.alert_request(), ["service"]))
      )

    assert json_response(conn, 422) == ControllersHelper.missing_field_response("service")
  end

  test "Request.SendNotification.Deep.AlertNotification schema without required alert field", %{
    conn: conn
  } do
    conn =
      post(
        conn,
        "/v2/notification/654321",
        Jason.encode!(Map.drop(ControllersHelper.alert_request(), ["alert"]))
      )

    assert json_response(conn, 422) == ControllersHelper.missing_field_response("alert")
  end

  test "Request.SendNotification.Deep.AlertNotification schema with incorrect priority value", %{
    conn: conn
  } do
    conn =
      post(
        conn,
        "/v2/notification/654321",
        Jason.encode!(%{
          ControllersHelper.alert_request()
          | "priority" => "the highest in the world"
        })
      )

    assert json_response(conn, 422) == ControllersHelper.no_schemas_provided_response()
  end

  test "Request.SendNotification.Deep.AlertNotification schema with unexpected field", %{
    conn: conn
  } do
    conn =
      post(
        conn,
        "/v2/notification/654321",
        Jason.encode!(Map.put(ControllersHelper.alert_request(), "field", "peek-a-boo"))
      )

    assert json_response(conn, 422) == ControllersHelper.no_schemas_provided_response()
  end

  test "correct Request.SendNotification.Deep.SilentNotification schema", %{conn: conn} do
    expect(MongoosePush.Notification.MockImpl, :push, fn _id, _req -> :ok end)

    conn =
      post(conn, "/v2/notification/654321", Jason.encode!(ControllersHelper.silent_request()))

    assert json_response(conn, 200) == nil
  end

  test "Request.SendNotification.Deep.SilentNotification schema without required service field",
       %{
         conn: conn
       } do
    conn =
      post(
        conn,
        "/v2/notification/654321",
        Jason.encode!(Map.drop(ControllersHelper.silent_request(), ["service"]))
      )

    assert json_response(conn, 422) == ControllersHelper.missing_field_response("service")
  end

  test "Request.SendNotification.Deep.SilentNotification schema without required data field", %{
    conn: conn
  } do
    conn =
      post(
        conn,
        "/v2/notification/654321",
        Jason.encode!(Map.drop(ControllersHelper.silent_request(), ["data"]))
      )

    assert json_response(conn, 422) == ControllersHelper.missing_field_response("alert")
  end

  test "Request.SendNotification.Deep.SilentNotification schema with incorrect time_to_live value",
       %{
         conn: conn
       } do
    conn =
      post(
        conn,
        "/v2/notification/654321",
        Jason.encode!(%{ControllersHelper.silent_request() | "time_to_live" => "infinity"})
      )

    assert json_response(conn, 422) == ControllersHelper.no_schemas_provided_response()
  end

  test "Request.SendNotification.Deep.SilentNotification schema with unexpected field", %{
    conn: conn
  } do
    conn =
      post(
        conn,
        "/v2/notification/654321",
        Jason.encode!(Map.put(ControllersHelper.silent_request(), "field", "peek-a-boo"))
      )

    assert json_response(conn, 422) == ControllersHelper.no_schemas_provided_response()
  end

  test "empty request", %{
    conn: conn
  } do
    conn =
      post(
        conn,
        "/v2/notification/654321",
        Jason.encode!(%{})
      )

    assert json_response(conn, 422) ==
             Map.merge(
               ControllersHelper.missing_field_response("service"),
               ControllersHelper.missing_field_response("alert"),
               fn _k, v1, v2 -> v1 ++ v2 end
             )
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

  test "AlertNotification decoder test: all possible fields", %{conn: conn} do
    device_id = "1"
    expected_device_id = "1"

    request = %{
      "service" => "apns",
      "mode" => "prod",
      "priority" => "normal",
      "time_to_live" => 3600,
      "mutable_content" => false,
      "tags" => ["some", "tags", "for", "pool", "selection"],
      "topic" => "com.someapp",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title",
        "badge" => 7,
        "click_action" => ".SomeApp.Handler.action",
        "tag" => "info",
        "sound" => "standard.mp3"
      }
    }

    expected_request = %{
      alert: %{
        badge: 7,
        body: "A message from someone",
        click_action: ".SomeApp.Handler.action",
        sound: "standard.mp3",
        tag: "info",
        title: "Notification title"
      },
      mode: :prod,
      service: :apns,
      topic: "com.someapp",
      priority: :normal,
      time_to_live: 3600,
      mutable_content: false,
      tags: ["some", "tags", "for", "pool", "selection"]
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "AlertNotification decoder test: all required fields", %{conn: conn} do
    device_id = "2"
    expected_device_id = "2"

    request = %{
      "service" => "fcm",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title"
      }
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      service: :fcm,
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "AlertNotification decoder test: alert.badge + alert.click_action fields", %{conn: conn} do
    device_id = "3"
    expected_device_id = "3"

    request = %{
      "service" => "apns",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title",
        "badge" => 7,
        "click_action" => ".SomeApp.Handler.action"
      }
    }

    expected_request = %{
      alert: %{
        badge: 7,
        body: "A message from someone",
        click_action: ".SomeApp.Handler.action",
        title: "Notification title"
      },
      service: :apns,
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "AlertNotification decoder test: alert.tag + alert.sound fields", %{conn: conn} do
    device_id = "4"
    expected_device_id = "4"

    request = %{
      "service" => "fcm",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title",
        "tag" => "info",
        "sound" => "standard.mp3"
      }
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        sound: "standard.mp3",
        tag: "info",
        title: "Notification title"
      },
      service: :fcm,
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "AlertNotification decoder test: time_to_live + mutable_content fields", %{conn: conn} do
    device_id = "5"
    expected_device_id = "5"

    request = %{
      "service" => "apns",
      "time_to_live" => 3600,
      "mutable_content" => true,
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title"
      }
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      service: :apns,
      time_to_live: 3600,
      mutable_content: true
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "AlertNotification decoder test: tags + topic fields", %{conn: conn} do
    device_id = "6"
    expected_device_id = "6"

    request = %{
      "service" => "apns",
      "tags" => ["some", "tags", "for", "pool", "selection"],
      "topic" => "com.someapp",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title"
      }
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      service: :apns,
      topic: "com.someapp",
      mutable_content: false,
      tags: ["some", "tags", "for", "pool", "selection"]
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "AlertNotification decoder test: mode :prod + priority :high fields", %{conn: conn} do
    device_id = "7"
    expected_device_id = "7"

    request = %{
      "service" => "fcm",
      "mode" => "prod",
      "priority" => "high",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title"
      }
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      mode: :prod,
      service: :fcm,
      priority: :high,
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "AlertNotification decoder test: mode :dev + priority :normal fields", %{conn: conn} do
    device_id = "8"
    expected_device_id = "8"

    request = %{
      "service" => "apns",
      "mode" => "dev",
      "priority" => "normal",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title"
      }
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      mode: :dev,
      service: :apns,
      priority: :normal,
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "SilentNotification decoder test: all possible fields", %{conn: conn} do
    device_id = "9"
    expected_device_id = "9"

    request = %{
      "service" => "apns",
      "mode" => "prod",
      "priority" => "normal",
      "time_to_live" => 3600,
      "mutable_content" => false,
      "tags" => ["some", "tags", "for", "pool", "selection"],
      "topic" => "com.someapp",
      "data" => %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected_request = %{
      data: %{"acme1" => "value1", "acme2" => "value2"},
      mode: :prod,
      service: :apns,
      topic: "com.someapp",
      priority: :normal,
      time_to_live: 3600,
      mutable_content: false,
      tags: ["some", "tags", "for", "pool", "selection"]
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "SilentNotification decoder test: all required fields", %{conn: conn} do
    device_id = "10"
    expected_device_id = "10"

    request = %{
      "service" => "apns",
      "data" => %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected_request = %{
      service: :apns,
      data: %{"acme1" => "value1", "acme2" => "value2"},
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "SilentNotification decoder test: time_to_live + mutable_content fields", %{conn: conn} do
    device_id = "11"
    expected_device_id = "11"

    request = %{
      "service" => "apns",
      "data" => %{"acme1" => "value1", "acme2" => "value2"},
      "time_to_live" => 3600,
      "mutable_content" => true
    }

    expected_request = %{
      service: :apns,
      data: %{"acme1" => "value1", "acme2" => "value2"},
      time_to_live: 3600,
      mutable_content: true
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "SilentNotification decoder test: tags + topic fields", %{conn: conn} do
    device_id = "12"
    expected_device_id = "12"

    request = %{
      "service" => "apns",
      "data" => %{"acme1" => "value1", "acme2" => "value2"},
      "tags" => ["some", "tags", "for", "pool", "selection"],
      "topic" => "com.someapp"
    }

    expected_request = %{
      service: :apns,
      data: %{"acme1" => "value1", "acme2" => "value2"},
      topic: "com.someapp",
      mutable_content: false,
      tags: ["some", "tags", "for", "pool", "selection"]
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "SilentNotification decoder test: mode :prod + priority :high fields", %{conn: conn} do
    device_id = "13"
    expected_device_id = "13"

    request = %{
      "service" => "fcm",
      "data" => %{"acme1" => "value1", "acme2" => "value2"},
      "mode" => "prod",
      "priority" => "high"
    }

    expected_request = %{
      mode: :prod,
      service: :fcm,
      data: %{"acme1" => "value1", "acme2" => "value2"},
      priority: :high,
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "SilentNotification decoder test: mode :dev + priority :normal fields", %{conn: conn} do
    device_id = "14"
    expected_device_id = "14"

    request = %{
      "service" => "apns",
      "data" => %{"acme1" => "value1", "acme2" => "value2"},
      "mode" => "dev",
      "priority" => "normal"
    }

    expected_request = %{
      mode: :dev,
      service: :apns,
      data: %{"acme1" => "value1", "acme2" => "value2"},
      priority: :normal,
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "MixedNotification decoder test: all possible fields", %{conn: conn} do
    device_id = "15"
    expected_device_id = "15"

    request = %{
      "service" => "fcm",
      "mode" => "prod",
      "priority" => "normal",
      "time_to_live" => 3600,
      "mutable_content" => false,
      "tags" => ["some", "tags", "for", "pool", "selection"],
      "topic" => "com.someapp",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title",
        "badge" => 7,
        "click_action" => ".SomeApp.Handler.action",
        "tag" => "info",
        "sound" => "standard.mp3"
      },
      "data" => %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected_request = %{
      alert: %{
        badge: 7,
        body: "A message from someone",
        click_action: ".SomeApp.Handler.action",
        sound: "standard.mp3",
        tag: "info",
        title: "Notification title"
      },
      data: %{"acme1" => "value1", "acme2" => "value2"},
      mode: :prod,
      service: :fcm,
      topic: "com.someapp",
      priority: :normal,
      time_to_live: 3600,
      mutable_content: false,
      tags: ["some", "tags", "for", "pool", "selection"]
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "MixedNotification decoder test: all required fields", %{conn: conn} do
    device_id = "16"
    expected_device_id = "16"

    request = %{
      "service" => "apns",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title",
        "badge" => 7,
        "click_action" => ".SomeApp.Handler.action",
        "tag" => "info",
        "sound" => "standard.mp3"
      },
      "data" => %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected_request = %{
      alert: %{
        badge: 7,
        body: "A message from someone",
        click_action: ".SomeApp.Handler.action",
        sound: "standard.mp3",
        tag: "info",
        title: "Notification title"
      },
      data: %{"acme1" => "value1", "acme2" => "value2"},
      service: :apns,
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "MixedNotification decoder test: alert.badge + alert.click_action fields", %{conn: conn} do
    device_id = "17"
    expected_device_id = "17"

    request = %{
      "service" => "fcm",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title",
        "badge" => 7,
        "click_action" => ".SomeApp.Handler.action"
      },
      "data" => %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected_request = %{
      alert: %{
        badge: 7,
        body: "A message from someone",
        click_action: ".SomeApp.Handler.action",
        title: "Notification title"
      },
      data: %{"acme1" => "value1", "acme2" => "value2"},
      service: :fcm,
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "MixedNotification decoder test: alert.tag + alert.sound fields", %{conn: conn} do
    device_id = "18"
    expected_device_id = "18"

    request = %{
      "service" => "apns",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title",
        "tag" => "info",
        "sound" => "standard.mp3"
      },
      "data" => %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        sound: "standard.mp3",
        tag: "info",
        title: "Notification title"
      },
      data: %{"acme1" => "value1", "acme2" => "value2"},
      service: :apns,
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "MixedNotification decoder test: time_to_live + mutable_content fields", %{conn: conn} do
    device_id = "19"
    expected_device_id = "19"

    request = %{
      "service" => "fcm",
      "time_to_live" => 3600,
      "mutable_content" => true,
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title"
      },
      "data" => %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      data: %{"acme1" => "value1", "acme2" => "value2"},
      service: :fcm,
      time_to_live: 3600,
      mutable_content: true
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "MixedNotification decoder test: tags + topic fields", %{conn: conn} do
    device_id = "20"
    expected_device_id = "20"

    request = %{
      "service" => "apns",
      "tags" => ["some", "tags", "for", "pool", "selection"],
      "topic" => "com.someapp",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title"
      },
      "data" => %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      data: %{"acme1" => "value1", "acme2" => "value2"},
      service: :apns,
      topic: "com.someapp",
      mutable_content: false,
      tags: ["some", "tags", "for", "pool", "selection"]
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "MixedNotification decoder test: mode :prod + priority :high fields", %{conn: conn} do
    device_id = "21"
    expected_device_id = "21"

    request = %{
      "service" => "fcm",
      "mode" => "prod",
      "priority" => "high",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title"
      },
      "data" => %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      data: %{"acme1" => "value1", "acme2" => "value2"},
      mode: :prod,
      service: :fcm,
      priority: :high,
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  test "MixedNotification decoder test: mode :dev + priority :normal fields", %{conn: conn} do
    device_id = "22"
    expected_device_id = "22"

    request = %{
      "service" => "apns",
      "mode" => "dev",
      "priority" => "normal",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title"
      },
      "data" => %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected_request = %{
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      data: %{"acme1" => "value1", "acme2" => "value2"},
      mode: :dev,
      service: :apns,
      priority: :normal,
      mutable_content: false
    }

    post_and_assert(conn, device_id, expected_device_id, request, expected_request)
  end

  defp post_and_assert_error_500(conn, type, reason) do
    device_id = "666"
    request = ControllersHelper.alert_request()

    expect(MongoosePush.Notification.MockImpl, :push, fn _device_id, _request ->
      {:error, {type, reason}}
    end)

    conn = post(conn, "/v2/notification/#{device_id}", Jason.encode!(request))

    assert json_response(conn, 500) == %{"details" => to_string(reason)}
  end

  defp post_and_assert(conn, device_id, expected_device_id, request, expected_request) do
    expect(MongoosePush.Notification.MockImpl, :push, fn device_id, request ->
      assert request == expected_request
      assert device_id == expected_device_id
      :ok
    end)

    post(conn, "/v2/notification/#{device_id}", Jason.encode!(request))
  end
end
