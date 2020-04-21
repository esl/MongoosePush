defmodule MongoosePushWeb.APIv3NotificationControllerTest do
  alias MongoosePushWeb.Support.ControllersHelper
  use MongoosePushWeb.ConnCase, async: true
  import Mox

  setup :verify_on_exit!

  setup %{conn: conn} do
    new_conn = put_req_header(conn, "content-type", "application/json")
    %{spec: MongoosePushWeb.ApiSpec.spec(), conn: new_conn}
  end

  test "correct Request.SendNotification.Deep.Alert schema", %{conn: conn} do
    expect(MongoosePushBehaviourMock, :push, fn _id, _req -> :ok end)

    conn = post(conn, "/v3/notification/123456", Jason.encode!(ControllersHelper.alert_request()))
    assert json_response(conn, 200) == nil
  end

  test "Request.SendNotification.Deep.Alert schema without required service field", %{conn: conn} do
    conn =
      post(
        conn,
        "/v3/notification/123456",
        Jason.encode!(Map.drop(ControllersHelper.alert_request(), ["service"]))
      )

    assert json_response(conn, 422) == ControllersHelper.no_schemas_provided_response()
  end

  test "Request.SendNotification.Deep.Alert schema without required alert field", %{conn: conn} do
    conn =
      post(
        conn,
        "/v3/notification/123456",
        Jason.encode!(Map.drop(ControllersHelper.alert_request(), ["alert"]))
      )

    assert json_response(conn, 422) == ControllersHelper.no_schemas_provided_response()
  end

  test "Request.SendNotification.Deep.Alert schema with incorrect priority value", %{conn: conn} do
    conn =
      post(
        conn,
        "/v3/notification/123456",
        Jason.encode!(%{
          ControllersHelper.alert_request()
          | "priority" => "the highest in the world"
        })
      )

    assert json_response(conn, 422) == ControllersHelper.no_schemas_provided_response()
  end

  test "Request.SendNotification.Deep.Alert schema with unexpected field", %{conn: conn} do
    conn =
      post(
        conn,
        "/v2/notification/123456",
        Jason.encode!(Map.put(ControllersHelper.alert_request(), "field", "peek-a-boo"))
      )

    assert json_response(conn, 422) == ControllersHelper.no_schemas_provided_response()
  end

  test "correct Request.SendNotification.Deep.Data schema", %{conn: conn} do
    expect(MongoosePushBehaviourMock, :push, fn _id, _req -> :ok end)

    conn = post(conn, "/v3/notification/123456", Jason.encode!(ControllersHelper.data_request()))
    assert json_response(conn, 200) == nil
  end

  test "Request.SendNotification.Deep.Data schema without required service field", %{conn: conn} do
    conn =
      post(
        conn,
        "/v3/notification/123456",
        Jason.encode!(Map.drop(ControllersHelper.data_request(), ["service"]))
      )

    assert json_response(conn, 422) == ControllersHelper.no_schemas_provided_response()
  end

  test "Request.SendNotification.Deep.Data schema without required data field", %{conn: conn} do
    conn =
      post(
        conn,
        "/v3/notification/123456",
        Jason.encode!(Map.drop(ControllersHelper.data_request(), ["data"]))
      )

    assert json_response(conn, 422) == ControllersHelper.no_schemas_provided_response()
  end

  test "Request.SendNotification.Deep.Data schema with incorrect time_to_live value", %{
    conn: conn
  } do
    conn =
      post(
        conn,
        "/v3/notification/123456",
        Jason.encode!(%{ControllersHelper.data_request() | "time_to_live" => "infinity"})
      )

    assert json_response(conn, 422) == ControllersHelper.no_schemas_provided_response()
  end

  test "Request.SendNotification.Deep.Data schema with unexpected field", %{conn: conn} do
    conn =
      post(
        conn,
        "/v3/notification/123456",
        Jason.encode!(Map.put(ControllersHelper.data_request(), "field", "peek-a-boo"))
      )

    assert json_response(conn, 422) == ControllersHelper.no_schemas_provided_response()
  end
end
