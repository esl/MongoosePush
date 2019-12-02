defmodule MongoosePush.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mongoose_push,
      version: "2.0.0-beta.2",
      elixir: "~> 1.5",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      dialyzer: dialyzer(),
      test_coverage: test_coverage(),
      preferred_cli_env: preferred_cli_env(),
      compilers: compilers(Mix.env()),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:lager, :logger, :runtime_tools], mod: {MongoosePush.Application, []}]
  end

  defp deps do
    [
      {:chatterbox, github: "joedevivo/chatterbox", ref: "ff0c2e0", override: true},
      {:sparrow, github: "esl/sparrow", ref: "571feb0dc"},
      {:maru, github: "rslota/maru", ref: "54fc038", override: true},
      {:plug_cowboy, "~> 2.0"},
      {:cowboy, "~> 2.3", override: true},
      {:jason, "~> 1.0"},
      {:poison, "~> 3.0"},
      {:maru_swagger, github: "elixir-maru/maru_swagger"},
      {:distillery, "~> 2.0", override: true},
      {:confex, "~> 3.2", override: true},
      {:mix_docker, "~> 0.5"},
      {:uuid, "~> 1.1"},
      {:lager, ">= 3.7.0", override: true},

      # Just overrides to make elixometer compile...
      {:exometer_core, github: "esl/exometer_core", override: true},
      {:exometer_report_graphite, github: "esl/exometer_report_graphite"},
      {:elixometer, github: "esl/elixometer"},

      # Below only :dev / :test deps
      {:mock, "~> 0.3", only: :test},
      # Until eproxus/meck  #fcc551e3 is in a release, we need to use master version
      # to include this commit (fixes mocking in Erlang 20.x + Elixir 1.5.x)
      {:meck, github: "eproxus/meck", override: true},
      {:httpoison, "~> 1.6.2"},
      {:excoveralls, "~> 0.7", only: :test},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: :dev},
      {:quixir, "~> 0.9", only: [:test, :integration]}
    ]
  end

  defp docs do
    [
      name: "MongoosePush",
      source_url: "https://github.com/esl/MongoosePush",
      homepage_url: "https://github.com/esl/MongoosePush",
      # The main page in the docs
      docs: [main: "MongoosePush", extras: ["README.md"]]
    ]
  end

  defp dialyzer do
    [
      plt_core_path: ".dialyzer/",
      flags: ["-Wunmatched_returns", "-Werror_handling", "-Wrace_conditions", "-Wunderspecs"]
    ]
  end

  defp test_coverage do
    [tool: ExCoveralls]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.travis": :test,
      "coveralls.html": :test
    ]
  end

  defp compilers(:integration), do: Mix.compilers()

  defp compilers(_) do
    Mix.compilers()
    |> List.delete(:erlang)
    |> Enum.concat([:asn1, :erlang])
  end

  defp aliases do
    [test: "test --no-start"]
  end

  # All mix tasks are redundant in runtime, but we still need to compile `lib/mix/tasks/compile_asn1.ex`
  # as it's required by build process (ASN1 compiler).

  defp elixirc_paths(:prod), do: ["lib"]

  defp elixirc_paths(:test), do: ["lib", "test/support"]

  defp elixirc_paths(:integration), do: ["test/api", "test/support"]

  defp elixirc_paths(_), do: ["lib"]
end
