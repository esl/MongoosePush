defmodule MongoosePushWeb.Plug.MaybePutSwaggerUI do
  @behaviour Plug

  @impl Plug
  def init(opts) do
    OpenApiSpex.Plug.SwaggerUI.init(opts)
  end

  @impl Plug
  def call(conn, opts) do
    OpenApiSpex.Plug.SwaggerUI.call(conn, opts)
  end
end
