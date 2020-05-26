defmodule TestHelper do
  @fcm_http_port 4001
  def reload_app(opts \\ []) do
    Application.stop(:mongoose_push)
    Application.stop(:sparrow)
    Application.unload(:mongoose_push)
    Application.put_env(:goth, :endpoint, "http://localhost:#{@fcm_http_port}")
    Application.load(:mongoose_push)

    Enum.each(opts, fn {key, value} ->
      Application.put_env(:mongoose_push, key, value)
    end)

    {:ok, _} = Application.ensure_all_started(:mongoose_push)
    :ok
  end
end
