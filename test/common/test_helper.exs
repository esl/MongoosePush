ExUnit.start(capture_log: true)

HTTPoison.start()

defmodule TimeHelper do
  def wait_until(fun), do: wait_until(500, fun)

  def wait_until(0, fun), do: fun.()

  def wait_until(timeout, fun) do
    try do
      fun.()
    rescue
      ExUnit.AssertionError ->
        :timer.sleep(10)
        wait_until(max(0, timeout - 10), fun)
    end
  end
end

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
