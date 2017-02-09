defmodule MongoosePush.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  import Supervisor.Spec

  @spec start(atom, list(term)) :: {:ok, pid}
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised

    children = fcm_workers(env(:fcm)) ++
               apns_workers(env(:apns))

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MongoosePush.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec pool_size(MongoosePush.service, atom) :: integer
  def pool_size(type, name), do: env(type)[name][:pool_size]

  @spec worker_name(atom, atom, integer) :: atom
  def worker_name(type, name, num), do: String.to_atom(~s"#{type}_#{name}_#{num}")

  @spec pools_by_mode(MongoosePush.service, MongoosePush.mode) :: list(atom)
  def pools_by_mode(:fcm = service, _mode) do
    config = env(service)

    config
    |> Enum.map(&(elem(&1, 0)))
  end

  def pools_by_mode(:apns = service, mode) do
    config = env(service)

    config
    |> Enum.group_by(&(mode(elem(&1, 1))), &(elem &1, 0))
    |> Map.get(mode)
  end

  @spec env(atom) :: term
  def env(var), do: Application.get_env(:mongoose_push, var)

  defp fcm_workers(nil), do: []
  defp fcm_workers(config) do
    workers = Enum.map(config, fn({pool_name, pool_config}) ->
      pool_config = translate_worker_config(:fcm, pool_config)

      Enum.map(1..pool_size(:fcm, pool_name), fn(id) ->
        worker_name = worker_name(:fcm, pool_name, id)
        worker(Pigeon.GCMWorker, [worker_name, pool_config], [id: worker_name])
      end)
    end)

    workers
    |> List.flatten
  end

  defp apns_workers(nil), do: []
  defp apns_workers(config) do
    workers = Enum.map(config, fn({pool_name, pool_config}) ->
      pool_config = translate_worker_config(:apns, pool_config)

      Enum.map(1..pool_size(:apns, pool_name), fn(id) ->
        worker_name = worker_name(:apns, pool_name, id)
        worker_config = Pigeon.APNS.Config.config(worker_name, pool_config)
        worker(Pigeon.APNSWorker, [worker_config], [id: worker_name])
      end)
    end)

    workers
    |> List.flatten
  end

  defp translate_worker_config(:fcm, config) do
    config
    |> fix_priv_paths()
    |> ensure_mode()
  end

  defp translate_worker_config(:apns, config) do
    config
    |> fix_priv_paths()
    |> ensure_mode()
    |> construct_apns_endpoint_options()
  end

  defp ensure_mode(config) do
    case config[:mode] do
      nil ->
        Enum.into([mode: mode(config)], config)
      _ ->
        config
    end
  end

  defp construct_apns_endpoint_options(config) do
    new_key = case mode(config) do
      :dev -> :development_endpoint
      :prod -> :production_endpoint
    end
    Enum.into([{new_key, config[:endpoint]}], config)
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
