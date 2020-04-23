defmodule MongoosePushWeb.APIv1NotificationControllerTest do
  alias MongoosePushWeb.Support.ControllersHelper
  use MongoosePushWeb.ConnCase, async: true
  import Mox

  setup :verify_on_exit!

  setup %{conn: conn} do
    new_conn = put_req_header(conn, "content-type", "application/json")
    %{spec: MongoosePushWeb.ApiSpec.spec(), conn: new_conn}
  end

  test "correct Request.SendNotification.Flat schema", %{conn: conn} do
    expect(MongoosePush.Notification.MockImpl, :push, fn _id, _req -> :ok end)

    conn = post(conn, "/v1/notification/666", Jason.encode!(ControllersHelper.flat_request()))
    assert json_response(conn, 200) == nil
  end

  test "Request.SendNotification.Flat schema without required service field", %{conn: conn} do
    conn =
      post(
        conn,
        "/v1/notification/666",
        Jason.encode!(Map.drop(ControllersHelper.flat_request(), ["service"]))
      )

    assert json_response(conn, 422) == ControllersHelper.missing_field_response("service")
  end

  test "Request.SendNotification.Flat schema without required body field", %{conn: conn} do
    conn =
      post(
        conn,
        "/v1/notification/666",
        Jason.encode!(Map.drop(ControllersHelper.flat_request(), ["body"]))
      )

    assert json_response(conn, 422) == ControllersHelper.missing_field_response("body")
  end

  test "Request.SendNotification.Flat schema with incorrect badge value", %{conn: conn} do
    conn =
      post(
        conn,
        "/v1/notification/666",
        Jason.encode!(%{ControllersHelper.flat_request() | "badge" => "seven"})
      )

    assert json_response(conn, 422) ==
             ControllersHelper.invalid_field_response("integer", "string", "badge")
  end

  test "Request.SendNotification.Flat schema with unexpected field", %{conn: conn} do
    conn =
      post(
        conn,
        "/v1/notification/666",
        Jason.encode!(Map.put(ControllersHelper.flat_request(), "field", "peek-a-boo"))
      )

    assert json_response(conn, 422) == ControllersHelper.unexpected_field_response("field")
  end
end
