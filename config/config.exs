# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :mongoose_push, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:mongoose_push, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

config :logger,
  backends: [LoggerLagerBackend],
  handle_otp_reports: false

import_config "#{Mix.env}.exs"

# Globally disable maru's "test mode". If we don't disable it explicitly
# it will crash a release.
# For test environment: for now it's not compatible.
config :maru, :test, false
