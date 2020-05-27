defmodule MongoosePushWeb.Plug.MaybePutSwaggerUI do
  import Plug.Conn
  @behaviour Plug

  @impl Plug
  def init(opts) do
    enable =
      Application.get_env(:mongoose_push, :openapi)[:expose_spec] &&
        Application.get_env(:mongoose_push, :openapi)[:expose_ui]

    opts =
      if enable do
        OpenApiSpex.Plug.SwaggerUI.init(opts)
      end

    %{enabled: enable, opts: opts}
  end

  @impl Plug
  def call(conn, %{enabled: enable, opts: opts}) when enable == false or opts == nil do
    conn
    |> send_resp(404, "swaggerUI disabled")
    |> halt()
  end

  @impl Plug
  def call(conn, %{opts: opts}) do
    OpenApiSpex.Plug.SwaggerUI.call(conn, opts)
  end
end
