defmodule MongoosePushWeb.DummyControllerTest do
    use MongoosePushWeb.ConnCase

    test "POST /api/dummy", %{conn: conn} do
        conn = post(conn, "/api/dummy")
        assert json_response(conn,200) == %{"body" => %{}}
    end

    test "POST /api/dummy with parameters", %{conn: conn} do
        conn = post(conn, "/api/dummy", [key: "value"])
        assert json_response(conn,200) == %{"body" => %{"key"=>"value"}}
      end
  end