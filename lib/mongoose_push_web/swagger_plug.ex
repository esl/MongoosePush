defmodule MongoosePushWeb.SwaggerPlug do
  use Plug.Builder

  @behaviour Plug

  @impl Plug
  def init(opts) do
    if(Application.get_env(:mongoose_push, :enable_swagger) == true) do
      OpenApiSpex.Plug.PutApiSpec.init(opts)
    end
  end

  @impl Plug
  def call(conn, nil) do
    conn
    |> put_status(404)
    |> halt()
  end
  def call(conn, opts) do
    OpenApiSpex.Plug.PutApiSpec.call(conn, opts)
  end
end
