ExUnit.start(capture_log: true)

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
  def reload_app() do
    Application.stop(:mongoose_push)
    Application.unload(:mongoose_push)
    Application.load(:mongoose_push)
    {:ok, _} = Application.ensure_all_started(:mongoose_push)
    :ok
  end
end
