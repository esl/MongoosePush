defmodule MongoosePush.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @typedoc "Possible keys in FCM config"
  @type fcm_key :: :key | :pool_size | :mode | :endpoint
  @typedoc "Possible keys in APNS config"
  @type apns_key :: :cert | :key | :pool_size | :mode | :endpoint | :use_2197

  @typedoc """
  In FCM `:key` and `:pool_size` are required and `:mode` has to be either `:dev` or `:prod`
  """
  @type fcm_config :: [{fcm_key, String.t() | atom | integer}]
  @typedoc """
  In APNS `:cert`, `:key` and `:pool_size` are required. `:mode` has to be either `:dev` or `:prod`
  """
  @type apns_config :: [{apns_key, String.t() | atom | integer}]

  @type pool_name :: atom()
  @type pool_definition :: {pool_name, fcm_config | apns_config}

  @spec start(atom, list(term)) :: {:ok, pid}
  def start(_type, _args) do
    # Logger setup
    loglevel = Application.get_env(:mongoose_push, :logging)[:level] || :info
    set_loglevel(loglevel)

    # Mostly status logging
    _ = check_runtime_configuration_status()

    # Define workers and child supervisors to be supervised
    children =
      service_children() ++ [MongoosePushWeb.Endpoint, MongoosePush.Metrics.TelemetryMetrics]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MongoosePush.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec pools_config(MongoosePush.service()) :: [pool_definition]
  def pools_config(service) do
    enabled_opt = String.to_atom(~s"#{service}_enabled")
    service_config = Application.get_env(:mongoose_push, service, nil)

    pools_config =
      case Application.get_env(:mongoose_push, enabled_opt, !is_nil(service_config)) do
        false -> []
        true -> service_config
      end

    Enum.map(Enum.with_index(pools_config), fn {{pool_name, pool_config}, index} ->
      normalized_pool_config =
        pool_config
        |> generate_pool_id(service, index)
        |> fix_priv_paths(service)
        |> ensure_mode()
        |> ensure_tls_opts()

      {pool_name, normalized_pool_config}
    end)
  end

  def services do
    Application.get_env(:mongoose_push, MongoosePush.Service)
  end

  def backend_module, do: Application.fetch_env!(:mongoose_push, :backend_module)

  defp service_children do
    List.foldl(services(), [], fn {service, module}, acc ->
      pools_config = pools_config(service)

      case pools_config do
        [] ->
          acc

        _ ->
          [module.supervisor_entry(pools_config) | acc]
      end
    end)
  end

  defp generate_pool_id(config, service, index) do
    id = String.to_atom("#{service}.pool.ID.#{index}")
    Keyword.merge(config, id: id)
  end

  defp ensure_mode(config) do
    case config[:mode] do
      nil ->
        Keyword.merge(config, mode: mode(config))

      _ ->
        config
    end
  end

  defp fix_priv_paths(config, service) do
    path_keys =
      case service do
        :apns ->
          [:cert, :key, :p8_file_path]

        :fcm ->
          [:appfile]
      end

    case service do
      :fcm ->
        check_paths(config, path_keys)

      :apns ->
        Keyword.update!(config, :auth, fn auth -> check_paths(auth, path_keys) end)
    end
  end

  defp check_paths(config, path_keys) do
    Enum.map(config, fn {key, value} ->
      case Enum.member?(path_keys, key) do
        true ->
          {key, Application.app_dir(:mongoose_push, value)}

        false ->
          {key, value}
      end
    end)
  end

  defp ensure_tls_opts(config) do
    case Application.get_env(:mongoose_push, :tls_server_cert_validation, nil) do
      false ->
        Keyword.put(config, :tls_opts, [])

      _ ->
        config
    end
  end

  defp mode(config), do: config[:mode] || :prod

  defp set_loglevel(level) do
    Logger.configure(level: level)

    # This project uses some Erlang deps, so lager may be present
    case Code.ensure_loaded?(:lager) do
      true ->
        :lager.set_loglevel(:lager_file_backend, level)
        :lager.set_loglevel(:lager_console_backend, level)

      false ->
        :ok
    end
  end

  defp check_runtime_configuration_status() do
    toml_configuration = Application.get_env(:mongoose_push, :toml_configuration)

    case toml_configuration[:status] do
      {:ok, :loaded} ->
        Logger.info("Loaded TOML configuration",
          what: :toml_configuration,
          status: :loaded,
          path: toml_configuration[:path]
        )

      {:ok, :skipped} ->
        Logger.info("Skipping TOML configuration due to file not present",
          what: :toml_configuration,
          status: :skipped,
          reason: :enoent,
          path: toml_configuration[:path]
        )

      {:error, reason} ->
        Logger.error("Unable to parse TOML config file",
          what: :toml_configuration,
          status: :error,
          reason: inspect(reason),
          path: toml_configuration[:path]
        )

      nil ->
        Logger.info("Skipping TOML configuration die to non-release boot",
          what: :toml_configuration,
          status: :error,
          reason: :no_release
        )
    end
  end
end
