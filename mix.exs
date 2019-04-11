defmodule MongoosePush.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mongoose_push,
      version: "1.0.3",
      elixir: "~> 1.5",
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
    [extra_applications: [:lager, :logger, :runtime_tools],
     mod: {MongoosePush.Application, []}]
  end

  defp deps do
    [
     {:chatterbox, github: "joedevivo/chatterbox", ref: "ff0c2e054430d2990b588afa6fb8f2d184dfeaea", override: true},
     {:pigeon, github: "rslota/pigeon", ref: "2860eee35b58e2d8674f805f1151f57b9faeca21"},

     {:maru,  github: "rslota/maru", ref: "54fc038", override: true},
     {:cowboy,  "~> 2.3", override: true},
     {:jason, "~> 1.0"},

     {:poison, "~> 3.0"},
     {:maru_swagger, github: "elixir-maru/maru_swagger"},
     {:distillery, "~> 2.0", override: true},
     {:confex, "~> 3.2", override: true},
     {:mix_docker, "~> 0.5"},
     {:uuid, "~> 1.1"},
     {:lager, ">= 3.6.9", override: true},
     {:logger_lager_backend, "~> 0.1.0"},

     # Just overrides to make elixometer compile...
     {:exometer_core, github: "esl/exometer_core", override: true},
     {:exometer_report_graphite, github: "esl/exometer_report_graphite"},
     {:elixometer, github: "esl/elixometer"},

     # Below only :dev / :test deps
     {:mock, "~> 0.3", only: :test},
     # Until eproxus/meck  #fcc551e3 is in a release, we need to use master version
     # to include this commit (fixes mocking in Erlang 20.x + Elixir 1.5.x)
     {:meck, github: "eproxus/meck", override: true},
     {:httpoison, "~> 0.13"},
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
