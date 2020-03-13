defmodule MongoosePushWeb.ApiController do
  use MongoosePushWeb, :controller

  def post(conn, params) do
    IO.inspect(params)
    json(conn, params)
  end
end
