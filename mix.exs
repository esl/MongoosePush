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

      # Docs
      name: "MongoosePush",
      source_url: "https://github.com/esl/MongoosePush",
      homepage_url: "https://github.com/esl/MongoosePush",
      docs: [main: "MongoosePush", # The main page in the docs
          extras: ["README.md"]],

      # Test Coverage
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html":  :test]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {MongoosePush.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
     {:pigeon, git: "https://github.com/rslota/pigeon.git", tag: "6d1e4e3"},
     {:maru, "~> 0.11"},
     {:poison, "~> 3.0"},
     {:httpoison, "~> 0.10.0"},
     {:maru_swagger, github: "elixir-maru/maru_swagger"},
     {:distillery, "~> 1.0"},
     # Below only :dev / :test deps
     {:mock, "~> 0.2.0", only: :test},
     {:excoveralls, "~> 0.6", only: :test},
     {:dialyxir, "~> 0.4", only: [:dev, :test], runtime: false},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:ex_doc, "~> 0.14", only: :dev}
    ]
  end
end
