# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: false

config :logger, :console,
  format: {MongoosePush.LoggerFmt, :format},
  metadata: :all

# Stop lager redirecting :error_logger messages
config :lager, :error_logger_redirect, false

# Stop lager removing Logger's :error_logger handler
config :lager, :error_logger_whitelist, [Logger.ErrorHandler]

config :plug, :statuses, %{
  460 => "Invalid device token"
}

lager_formater_config = [
  :date,
  'T',
  :time,
  :color,
  ' [',
  :severity,
  '] ',
  'pid=',
  :pid,
  '  ',
  :message,
  '\e[0m\r\n'
]

config :lager,
  colored: false,
  handlers: [
    lager_console_backend: [
      level: :info,
      formatter: :lager_default_formatter,
      formatter_config: lager_formater_config
    ],
    lager_file_backend: [
      file: 'log/error.log',
      level: :error,
      formatter: :lager_default_formatter,
      formatter_config: lager_formater_config
    ],
    lager_file_backend: [
      file: 'log/console.log',
      level: :info,
      formatter: :lager_default_formatter,
      formatter_config: lager_formater_config
    ]
  ]

config :sparrow, Sparrow.PoolsWarden, %{enabled: true}

import_config "#{Mix.env()}.exs"

# Globally disable maru's "test mode". If we don't disable it explicitly
# it will crash a release.
# For test environment: for now it's not compatible.
config :maru, :test, false

config :phoenix, :json_library, Jason
