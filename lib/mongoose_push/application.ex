defmodule MongoosePush.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @spec start(atom, list(term)) :: {:ok, pid}
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised

    children = List.flatten(workers())

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MongoosePush.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec pools_config(MongoosePush.service) :: term
  def pools_config(service) do
    pools_config = Application.get_env(:mongoose_push, service)

    Enum.map(pools_config, fn({pool_name, pool_config}) ->
      normalized_pool_config =
        pool_config
        |> fix_priv_paths()
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

  defp fix_priv_paths(config) do
    path_keys = [:cert, :key]
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

end
