defmodule Mix.Tasks.Test.Env.Up do
  use Mix.Task

  alias Mix.Tasks.Test.Env.Utils

  @shortdoc "Starts test/test.integration dependencies via docker-compose"

  @spec run(term) :: :ok
  def run(_args) do
    case System.find_executable("docker-compose") do
      nil ->
        Utils.flunk("`docker-compose` binary has to be present in your PATH!")

      compose_binary ->
        :ok = Utils.compose(compose_binary, ["up", "--build", "-d"])
    end
  end
end
