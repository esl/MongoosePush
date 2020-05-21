defmodule Mix.Tasks.Test.Env.Wait do
  use Mix.Task

  alias Mix.Tasks.Test.Env.Utils

  @shortdoc "Checks test/test.integration dependencies"

  @spec run(term) :: :ok
  def run([]), do: run(["5000"])

  def run([time | _]) do
    :ok = Utils.wait_for_services(String.to_integer(time))
  end
end
