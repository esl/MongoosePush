defmodule MongoosePushWeb.Plug.MaybeRenderSpec do
  @behaviour Plug

  @impl Plug
  def init(opts) do
    OpenApiSpex.Plug.RenderSpec.init(opts)
  end

  @impl Plug
  def call(conn, opts) do
    OpenApiSpex.Plug.RenderSpec.call(conn, opts)
  end
end
