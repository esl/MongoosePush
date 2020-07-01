defmodule Mix.Tasks.GhPagesDocs do
  use Mix.Task

  alias Mix.Project

  @moduledoc """
  Task for updating existing documentation version published on GH Pages.
  """

  @shortdoc "Update a documentation version on GH Pages."

  @spec run(term) :: :ok
  def run(_args) do
    version = "v#{Project.config()[:version]}"

    case File.read!("assets/js/versions.js") |> String.contains?(version) do
      true ->
        Mix.Task.run("docs")
        File.cd!("doc")
        Mix.shell().cmd("git stash")

        Mix.shell().cmd("git checkout gh-pages")

        case File.mkdir("../#{version}") do
          result when result in [:ok, {:error, :eexist}] ->
            Mix.shell().cmd("cp -r ./* ../#{version}")
            File.cd!("..")
            Mix.shell().cmd("ls")
            Mix.shell().cmd("git add #{version}/*")
            Mix.shell().cmd("git commit -m \"Update #{version}\"")
            Mix.shell().cmd("rm -rf doc")

          _ ->
            Mix.raise("Cannot create the #{version} directory")
        end

      _ ->
        Mix.raise("""
        The assets/js/versions.js file is out of date.
        Please add the newest version to the list.
        """)
    end
  end
end
