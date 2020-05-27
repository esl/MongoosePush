defmodule MongoosePushWeb.Plug.MaybeRenderSpec do
  import Plug.Conn
  @behaviour Plug

  @impl Plug
  def init(opts) do
    enable = Application.get_env(:mongoose_push, :openapi)[:expose_spec]

    opts =
      if enable do
        OpenApiSpex.Plug.RenderSpec.init(opts)
      end

    %{enabled: enable, opts: opts}
  end

  @impl Plug
  def call(conn, %{enabled: false}) do
    conn
    |> send_resp(404, "swagger.json access disabled")
    |> halt()
  end

  @impl Plug
  def call(conn, %{opts: opts}) do
    OpenApiSpex.Plug.RenderSpec.call(conn, opts)
  end
end
