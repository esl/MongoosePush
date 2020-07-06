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

    version =
      case version do
        "latest" -> Project.config()[:version]
        tag -> "v#{tag}"
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

        update_index_html()

        Mix.shell().cmd("git add assets/js/versions.js")
        Mix.shell().cmd("git add index.html")
        Mix.shell().cmd("git commit -m \"Add content for #{version}\"")
        Mix.shell().cmd("rm -rf doc")
        Mix.shell().cmd("git show ")
        Mix.shell().cmd("git push origin gh-pages")

      _ ->
        Mix.raise("Cannot create the #{version} directory")
    end
  end

  defp update_versions_js() do
    current = Project.config()[:version]
    {output, 0} = System.cmd("git", ["tag"], [])

    versions =
      output
      |> String.split("\n")
      |> Enum.drop(7)
      |> Enum.drop(-1)
      |> List.insert_at(0, current)
      |> Enum.map(&version_elem/1)
      |> Enum.join(",\n")

    File.write!("assets/js/versions.js", "var versionNodes = [\n#{versions}\n]")
  end

  def update_index_html() do
    current = Project.config()[:version]

    content = """
    <html>
      <head>
        <meta http-equiv="refresh" content="0;url=https://esl.github.io/MongoosePush/v#{current}/readme.html" />
          <title></title>
      </head>
      <body></body>
    </html>
    """

    File.write!("index.html", content)
  end

  defp version_elem(version) do
    "\t {\n\t\tversion: \"v#{version}\",
     \turl: \"https://esl.github.io/MongoosePush/v#{version}/readme.html\"\n\t }"
  end
end
