defmodule MongoosePushWeb.DummyController do
    use MongoosePushWeb, :controller

    def handle(conn, params) do
        json(conn, %{body: params})
    end
end