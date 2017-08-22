defmodule MongoosePush.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @spec start(atom, list(term)) :: {:ok, pid}
  def start(_type, _args) do
    # Logger setup
    loglevel = Confex.get_env(:mongoose_push, :loglevel, :info)
    set_loglevel(loglevel)

    # Define workers and child supervisors to be supervised
    children = List.flatten(workers())

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MongoosePush.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec pools_config(MongoosePush.service) :: term
  def pools_config(service) do
    enabled_opt = String.to_atom(~s"#{service}_enabled")
    pools_config =
      case Confex.get_env(:mongoose_push, enabled_opt, true) do
        false ->  []
        true  ->  Confex.fetch_env!(:mongoose_push, service)
      end

    Enum.map(pools_config, fn({pool_name, pool_config}) ->
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

  defp workers do
    for {service, module} <- services() do
      pools_config = pools_config(service)
      Enum.map(pools_config, &module.workers/1)
    end
  end

  defp ensure_mode(config) do
    case config[:mode] do
      nil ->
        Enum.into([mode: mode(config)], config)
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
          []
      end
    config
    |> Enum.map(fn({key, value}) ->
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
