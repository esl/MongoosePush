defmodule MongoosePushWeb.ApiControllerTest do
  use MongoosePushWeb.ConnCase
  alias MongoosePushWeb.Router.Helpers, as: Routes

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end

  test "POST /simple", %{conn: conn} do
    body = %{service: :fcm, body: "body", title: "title"}
    json = Poison.encode!(body)
    conn = post(conn, "/simple", json)
    json_response(conn, 200)
  end
end
