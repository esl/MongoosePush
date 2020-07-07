defmodule Mix.Tasks.GhPagesDocs do
  use Mix.Task

  alias Mix.Project

  @moduledoc """
  Task for updating existing documentation version published on GH Pages.
  """

  @shortdoc "Update a documentation version on GH Pages."

  @spec run(term) :: :ok
  def run([version]) do
    unless String.contains?(File.read!("assets/js/versions.js"), version) do
      update_versions_js()
    end

    version =
      case version do
        "latest" -> Project.config()[:version]
        tag -> "v#{tag}"
      end

    Mix.Task.run("docs")
    File.cd!("doc")
    0 = Mix.shell().cmd("git stash")

    # ignore all the changes, the only changes we want to track are in the
    # doc directory which is listed in .gitignore

    0 = Mix.shell().cmd("git checkout gh-pages")

    case File.mkdir("../#{version}") do
      result when result in [:ok, {:error, :eexist}] ->
        0 = Mix.shell().cmd("cp -r ./* ../#{version}")
        File.cd!("..")
        0 = Mix.shell().cmd("git add #{version}/*")

        unless String.contains?(File.read!("assets/js/versions.js"), version) do
          update_versions_js()
        end

        update_index_html()

        0 = Mix.shell().cmd("git add assets/js/versions.js")
        0 = Mix.shell().cmd("git add index.html")
        0 = Mix.shell().cmd("git commit -m \"Add content for #{version}\"")
        0 = Mix.shell().cmd("rm -rf doc")
        0 = Mix.shell().cmd("git push origin gh-pages")

      _ ->
        Mix.raise("Cannot create the #{version} directory")
    end
  end

  defp update_versions_js() do
    current = Project.config()[:version]
    {output, 0} = System.cmd("git", ["tag"], [])

    versions = [
      current
      # we skip the old releases and generate from 1.0.6 on
      | String.split(output, "\n") --
          [
            "0.1.0",
            "0.10.0",
            "0.9.0",
            "1.0.0",
            "1.0.3",
            "1.0.4",
            "1.0.5"
          ]
    ]

    versions
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
