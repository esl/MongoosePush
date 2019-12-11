ExUnit.start(capture_log: true)

HTTPoison.start()

defmodule TestHelper do
  @fcm_http_port 4001
  def reload_app() do
    Application.stop(:mongoose_push)
    Application.stop(:sparrow)
    Application.unload(:mongoose_push)
    Application.put_env(:goth, :endpoint, "http://localhost:#{@fcm_http_port}")
    Application.load(:mongoose_push)
    {:ok, _} = Application.ensure_all_started(:mongoose_push)
    :ok
  end
end
