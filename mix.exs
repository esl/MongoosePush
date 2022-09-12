defmodule MongoosePush.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mongoose_push,
      version: "2.1.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      dialyzer: dialyzer(),
      test_coverage: test_coverage(),
      preferred_cli_env: preferred_cli_env(),
      compilers: compilers(Mix.env()),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: elixirc_options(),
      test_paths: test_paths(Mix.env()),
      name: "MongoosePush",
      source_url: "https://github.com/esl/MongoosePush",
      homepage_url: "https://esl.github.io/MongoosePush"
    ]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      extra_applications: [:lager, :logger, :runtime_tools],
      mod: {MongoosePush.Application, []}
    ]
  end

  defp deps do
    [
      {:chatterbox, github: "joedevivo/chatterbox", ref: "1f4ce4f", override: true},
      {:sparrow, github: "esl/sparrow", ref: "1760502"},
      {:plug_cowboy, "~> 2.2"},
      {:jason, "~> 1.0"},
      {:poison, "~> 3.0", override: true},
      {:distillery, "~> 2.0", override: true},
      {:confex, "~> 3.2", override: true},
      {:mix_docker, "~> 0.5"},
      {:uuid, "~> 1.1"},
      {:lager, ">= 3.7.0", override: true},
      {:phoenix, "~> 1.6"},
      {:open_api_spex, "3.7.0"},
      {:toml, "~> 0.6.1"},
      {:asn1_compiler, "~> 0.1.1"},

      # Below only :dev / :test deps
      {:httpoison, "~> 1.6.2"},
      {:excoveralls, "~> 0.7", only: :test},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: :dev},
      {:quixir, "~> 0.9", only: [:test, :integration]},
      {:assert_eventually, "~> 0.2.0", only: [:test, :integration]},
      {:mox, "~> 0.5.2", only: [:test, :integration]},
      {:telemetry, "~>0.4.1"},
      {:telemetry_metrics, "~> 0.5"},
      {:telemetry_metrics_prometheus_core, "~> 0.4"},
      {:telemetry_poller, "~> 0.5"},
      {:logfmt, "~>3.3"},
      {:stream_data, "~> 0.5", only: :test}
    ]
  end

  defp docs do
    [
      javascript_config_path: "../assets/js/versions.js",
      extras: [
        "README.md": [file: "guides/readme", title: "Introduction"],
        "guides/configuration.md": [file: "guides/configuration", title: "Configuration"],
        "guides/local_build.md": [file: "guides/local_build", title: "Local build"],
        "guides/test.md": [file: "guides/test", title: "Running tests"],
        "guides/docker.md": [file: "guides/docker", title: "Docker"],
        "guides/http_api.md": [file: "guides/http_api", title: "HTTP API"],
        "guides/healthcheck.md": [file: "guides/healthcheck", title: "Healthcheck"],
        "guides/metrics.md": [file: "guides/metrics", title: "Metrics"]
      ],
      extra_section: "Guides",
      groups_for_modules: [
        API: [
          MongoosePush.API,
          MongoosePush.API.V1.ResponseEncoder,
          MongoosePush.API.V2.ResponseEncoder,
          MongoosePush.API.V3.ResponseEncoder
        ],
        Configuration: [
          MongoosePush.Config.Provider.Confex,
          MongoosePush.Config.Provider.Toml,
          MongoosePush.Config.Utils
        ],
        "Logs format": [
          MongoosePush.Logger.Common,
          MongoosePush.Logger.JSON,
          MongoosePush.Logger.LogFmt
        ],
        Metrics: [MongoosePush.Metrics.TelemetryMetrics],
        "Push notification services": [
          MongoosePush.Service,
          MongoosePush.Service.APNS,
          MongoosePush.Service.APNS.ErrorHandler,
          MongoosePush.Service.APNS.State,
          MongoosePush.Service.APNS.Supervisor,
          MongoosePush.Service.FCM,
          MongoosePush.Service.FCM.ErrorHandler,
          MongoosePush.Service.FCM.Pool.Supervisor,
          MongoosePush.Service.FCM.Pools
        ],
        Web: [
          MongoosePushWeb,
          MongoosePushWeb.APIv1.NotificationController,
          MongoosePushWeb.APIv2.NotificationController,
          MongoosePushWeb.APIv3.NotificationController,
          MongoosePushWeb.ApiSpec,
          MongoosePushWeb.Endpoint,
          MongoosePushWeb.PrometheusMetricsController,
          MongoosePushWeb.Router,
          MongoosePushWeb.Router.Helpers
        ],
        "Protocols and plugs": [
          MongoosePushWeb.Plug.CastAndValidate,
          MongoosePushWeb.Plug.CastAndValidate.StubAdapter,
          MongoosePushWeb.Plug.MaybePutSwaggerUI,
          MongoosePushWeb.Plug.MaybeRenderSpec,
          MongoosePushWeb.Protocols.RequestDecoder,
          MongoosePushWeb.Protocols.RequestDecoderHelper
        ],
        Schemas: [
          MongoosePushWeb.Schemas,
          MongoosePushWeb.Schemas.Request.SendNotification.Deep,
          MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertNotification,
          MongoosePushWeb.Schemas.Request.SendNotification.Deep.Common.Alert,
          MongoosePushWeb.Schemas.Request.SendNotification.Deep.Common.Data,
          MongoosePushWeb.Schemas.Request.SendNotification.Deep.MixedNotification,
          MongoosePushWeb.Schemas.Request.SendNotification.Deep.SilentNotification,
          MongoosePushWeb.Schemas.Request.SendNotification.FlatNotification,
          MongoosePushWeb.Schemas.Response.SendNotification.GenericError,
          MongoosePushWeb.Schemas.Response.SendNotification.Gone,
          MongoosePushWeb.Schemas.Response.SendNotification.PayloadTooLarge,
          MongoosePushWeb.Schemas.Response.SendNotification.ServiceUnavailable,
          MongoosePushWeb.Schemas.Response.SendNotification.TooManyRequests,
          MongoosePushWeb.Schemas.Response.SendNotification.UnknownError
        ]
      ],
      api_reference: false,
      main: "readme"
    ]
  end

  defp dialyzer do
    [
      plt_core_path: ".dialyzer/",
      plt_add_apps: [:ex_unit, :mix],
      flags: [
        "-Wunmatched_returns",
        "-Werror_handling",
        "-Wrace_conditions",
        "-Wunderspecs"
      ]
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
      "coveralls.html": :test,
      "test.integration": :integration
    ]
  end

  defp compilers(:integration), do: Mix.compilers()

  defp compilers(_) do
    [:asn1] ++ Mix.compilers()
  end

  defp aliases do
    [
      test: ["test.env.wait 5000", "test --no-start"]
    ]
  end

  defp elixirc_options do
    [warnings_as_errors: true]
  end

  defp elixirc_paths(:prod), do: ["lib"]

  defp elixirc_paths(:test), do: ["lib", "test/support"]

  defp elixirc_paths(:integration), do: ["test/support", "lib/mix"]

  defp elixirc_paths(:dev), do: ["lib", "test/support/mix"]

  defp elixirc_paths(_), do: ["lib"]

  defp test_paths(:integration), do: ["test/integration", "test/common"]

  defp test_paths(_), do: ["test/unit", "test/common", "test/mongoose_push_web"]
end
