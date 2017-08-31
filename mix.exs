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
      preferred_cli_env: preferred_cli_env(),
      compilers: compilers()
    ]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :runtime_tools],
     mod: {MongoosePush.Application, []}]
  end

  defp deps do
    [
     {:pigeon, github: "rslota/pigeon"},
     {:maru, "~> 0.12", override: true},
     {:poison, "~> 3.0"},
     {:httpoison, "~> 0.12.0"},
     {:maru_swagger, github: "elixir-maru/maru_swagger"},
     {:distillery, "~> 1.5"},
     {:confex, "~> 3.2", override: true},
     {:mix_docker, "~> 0.3"},
     { :uuid, "~> 1.1" },

     # Just overrides to make elixometer compile...
     {:setup, github: "uwiger/setup", tag: "1.8.0", override: true, manager: :rebar},
     {:edown, github: "uwiger/edown", tag: "0.8", override: true},
     {:lager, ">= 3.2.1", override: true},
     {:exometer_core, github: "PSPDFKit-labs/exometer_core", override: true},
     {:exometer, github: "PSPDFKit-labs/exometer"},
     {:elixometer, github: "pinterest/elixometer"},

     # Below only :dev / :test deps
     {:chatterbox, github: "rslota/chatterbox", override: true},
     {:mock, "~> 0.3.0", only: :test},
     # Until eproxus/meck  #fcc551e3 is in a release, we need to use master version
     # to include this commit (fixes mocking in Erlang 20.x + Elixir 1.5.x)
     {:meck, github: "eproxus/meck", override: true},
     {:excoveralls, "~> 0.7", only: :test},
     {:dialyxir, "~> 0.4", only: [:dev, :test], runtime: false},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:ex_doc, "~> 0.14", only: :dev},
     {:quixir, "~> 0.9", only: :test}
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

  defp compilers do
    Mix.compilers()
    |> List.delete(:erlang)
    |> Enum.concat([:asn1, :erlang])
  end
end
