defmodule MongoosePushWeb.Plug.CastAndValidate do
  @behaviour Plug

  @impl Plug
  def init(opts) do
    OpenApiSpex.Plug.CastAndValidate.init(opts)
  end

  @impl Plug
  def call(conn, opts) do
    OpenApiSpex.Plug.CastAndValidate.call(conn, opts)
  end
end