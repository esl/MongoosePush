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
    loglevel = Confex.get_env(:mongoose_push, :loglevel, :info)
    set_loglevel(loglevel)

    # Define workers and child supervisors to be supervised
    children = children()

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MongoosePush.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec pools_config(MongoosePush.service()) :: [pool_definition]
  def pools_config(service) do
    enabled_opt = String.to_atom(~s"#{service}_enabled")
    service_config = Confex.get_env(:mongoose_push, service, nil)

    pools_config =
      case Confex.get_env(:mongoose_push, enabled_opt, !is_nil(service_config)) do
        false -> []
        true -> service_config
      end

    Enum.map(pools_config, fn {pool_name, pool_config} ->
      normalized_pool_config =
        pool_config
        |> fix_priv_paths(service)
        |> ensure_mode()

      {pool_name, normalized_pool_config}
    end)
  end

  def services do
    [
      fcm: MongoosePush.Service.FCM,
      apns: MongoosePush.Service.APNS
    ]
  end

  defp children do
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
          [:cert, :key]

        :fcm ->
          [:appfile]
      end

    config
    |> Enum.map(fn {key, value} ->
      case Enum.member?(path_keys, key) do
        true ->
          {key, Application.app_dir(:mongoose_push, value)}

        false ->
          {key, value}
      end
    end)
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
end
