defmodule Mix.Tasks.GhPagesDocs do
  use Mix.Task

  alias Mix.Project

  @moduledoc """
  Task for updating existing documentation version published on GH Pages.
  """

  @shortdoc "Update a documentation version on GH Pages."

  @spec run([String.t()]) :: :ok
  def run([version]) do
    version =
      case version do
        "latest" -> "v#{Project.config()[:version]}"
        tag -> prefix_tag(tag)
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
          update_versions_js(version)
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

  def update_versions_js(current) do
    {tags, 0} = System.cmd("git", ["tag"], [])

    previous_versions =
      tags
      |> String.trim()
      |> String.split("\n")
      |> Enum.reverse()
      |> Enum.map(&prefix_tag/1)

    versions = [
      current
      # we skip the old releases and generate from 1.0.6 on
      | previous_versions --
          [
            "v0.1.0",
            "v0.10.0",
            "v0.9.0",
            "v1.0.0",
            "v1.0.3",
            "v1.0.4",
            "v1.0.5"
          ]
    ]

    versions_json =
      versions
      |> Enum.map(&version_elem/1)
      |> Enum.join(",\n")

    File.write!("assets/js/versions.js", "var versionNodes = [\n#{versions_json}\n]")
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
    "\t {\n\t\tversion: \"#{version}\",
     \turl: \"https://esl.github.io/MongoosePush/#{version}/readme.html\"\n\t }"
  end

  defp prefix_tag(tag) do
    "v#{tag}"
  end
end
