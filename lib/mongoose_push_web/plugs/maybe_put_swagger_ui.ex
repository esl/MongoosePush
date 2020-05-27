defmodule MongoosePushWeb.Plug.MaybePutSwaggerUI do
  import Plug.Conn
  @behaviour Plug

  @impl Plug
  def init(opts) do
    config = Application.get_env(:mongoose_push, :openapi)
    enable = config[:expose_spec] && config[:expose_ui]

    opts =
      if enable do
        OpenApiSpex.Plug.SwaggerUI.init(opts)
      end

    %{enabled: enable, opts: opts}
  end

  @impl Plug
  def call(conn, %{enabled: false}) do
    conn
    |> send_resp(404, "swaggerUI disabled")
    |> halt()
  end

  @impl Plug
  def call(conn, %{opts: opts}) do
    OpenApiSpex.Plug.SwaggerUI.call(conn, opts)
  end
end
