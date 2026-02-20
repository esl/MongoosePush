defmodule Mix.Tasks.Test.Env.Down do
  use Mix.Task

  alias Mix.Tasks.Test.Env.Utils

  @shortdoc "Stops test/test.integration dependencies via docker compose"

  @spec run(term) :: :ok
  def run(_args) do
    case System.find_executable("docker") do
      nil ->
        Utils.flunk("`docker` binary has to be present in your PATH!")

      docker_binary ->
        :ok = Utils.compose(docker_binary, ["down"])
    end
  end
end
