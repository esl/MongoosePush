defmodule Mix.Tasks.GhPagesDocs do
  use Mix.Task

  alias Mix.Project

  @moduledoc """
  Task for updating existing documentation version published on GH Pages.
  """

  @shortdoc "Update a documentation version on GH Pages."

  @spec run(term) :: :ok
  def run([version]) do
    unless File.read!("assets/js/versions.js") |> String.contains?(version) do
      update_versions_js()
    end

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

        unless File.read!("assets/js/versions.js") |> String.contains?(version) do
          update_versions_js()
        end

        Mix.shell().cmd("git add assets/js/versions.js")
        Mix.shell().cmd("git commit -m \"Add content for #{version}\"")
        Mix.shell().cmd("rm -rf doc")
        Mix.shell().cmd("git show ")
        Mix.shell().cmd("git push origin gh-pages")

      _ ->
        Mix.raise("Cannot create the #{version} directory")
    end
  end

  defp update_versions_js() do
    {output, 0} = System.cmd("git", ["tag"], [])

    versions =
      output
      |> String.split("\n")
      |> Enum.drop(7)
      |> Enum.drop(-1)
      |> Enum.map(&v/1)
      |> List.insert_at(0, "latest")
      |> Enum.map(&version_elem/1)
      |> Enum.join(",\n")

    File.write!("assets/js/versions.js", "var versionNodes = [\n#{versions}\n]")
  end

  defp v(version), do: "v#{version}"

  defp version_elem(version) do
    "\t {\n\t\tversion: \"#{version}\",
     \turl: \"https://esl.github.io/MongoosePush/#{version}/readme.html\"\n\t }"
  end
end
