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
     {:pigeon, github: "rslota/pigeon", tag: "087bb38"},
     {:maru, github: "elixir-maru/maru", tag: "7a24d1a3", override: true},
     {:poison, "~> 3.0"},
     {:httpoison, "~> 0.11.0"},
     {:maru_swagger, github: "elixir-maru/maru_swagger"},
     {:distillery, "~> 1.0"},
     {:confex, "~> 1.4", override: true},
     {:mix_docker, "~> 0.3"},

     # Just overrides to make elixometer compile...
     {:setup, github: "uwiger/setup", tag: "1.8.0", override: true, manager: :rebar},
     {:edown, github: "uwiger/edown", tag: "0.8", override: true},
     {:lager, ">= 3.2.1", override: true},
     {:exometer_core, github: "PSPDFKit-labs/exometer_core", override: true},
     {:exometer, github: "PSPDFKit-labs/exometer"},
     {:elixometer, github: "pinterest/elixometer"},


     # Below only :dev / :test deps
     {:chatterbox, github: "rslota/chatterbox", tag: "20f0096", override: true},
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
