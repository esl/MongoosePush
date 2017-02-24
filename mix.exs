defmodule MongoosePush.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mongoose_push,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      docs: docs(),
      dialyzer: dialyzer(),
      test_coverage: test_coverage(),
      preferred_cli_env: preferred_cli_env()
    ]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {MongoosePush.Application, []}]
  end

  defp deps do
    [
     {:pigeon, git: "https://github.com/rslota/pigeon.git", tag: "6d1e4e3"},
     {:maru, git: "https://github.com/rslota/maru.git", tag: "7c1da75", override: true},
     {:poison, "~> 3.0"},
     {:httpoison, "~> 0.10.0"},
     {:maru_swagger, github: "elixir-maru/maru_swagger"},
     {:distillery, "~> 1.0"},
     {:confex, "~> 1.4", override: true},
     {:mix_docker, "~> 0.3"},
     # Below only :dev / :test deps
     {:mock, "~> 0.2.0", only: :test},
     {:excoveralls, "~> 0.6", only: :test},
     {:dialyxir, "~> 0.4", only: [:dev, :test], runtime: false},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  defp docs do
    [name: "MongoosePush",
     source_url: "https://github.com/esl/MongoosePush",
     homepage_url: "https://github.com/esl/MongoosePush",
     docs: [main: "MongoosePush", # The main page in the docs
          extras: ["README.md"]]]
  end

  defp dialyzer do
    [plt_core_path: ".dialyzer/",
     flags: ["-Wunmatched_returns", "-Werror_handling",
             "-Wrace_conditions", "-Wunderspecs"]]
  end

  defp test_coverage do
    [tool: ExCoveralls]
  end

  defp preferred_cli_env do
    ["coveralls": :test, "coveralls.detail": :test,
     "coveralls.travis": :test, "coveralls.html": :test]
  end
end
