defmodule MongoosePush.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  import Supervisor.Spec

  def start(_type, _args) do
    # Define workers and child supervisors to be supervised

    children = fcm_workers(env(:fcm)) ++
               apns_workers(env(:apns))

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MongoosePush.Supervisor]
    Supervisor.start_link(children, opts)
  end


  defp fcm_workers(nil), do: []
  defp fcm_workers(config) do
    Enum.map(config, fn({pool_name, pool_config}) ->
      Enum.map(1..pool_size(:fcm, pool_name), fn(id) ->
        worker_name = worker_name(:fcm, pool_name, id)
        worker(Pigeon.GCMWorker, [worker_name, pool_config], [id: worker_name])
      end)
    end)
    |> List.flatten
  end

  defp apns_workers(nil), do: []
  defp apns_workers(config) do
    Enum.map(config, fn({pool_name, pool_config}) ->
      Enum.map(1..pool_size(:apns, pool_name), fn(id) ->
        worker_name = worker_name(:apns, pool_name, id)
        worker_config = Pigeon.APNS.Config.config(worker_name, pool_config)
        worker(Pigeon.APNSWorker, [worker_config], [id: worker_name])
      end)
    end)
    |> List.flatten
  end

  def pool_size(type, name), do: env(type)[name][:pool_size]
  def worker_name(type, name, num), do: String.to_atom(~s"#{type}_#{name}_#{num}")

  def pools_by_mode(:fcm, _mode) do
    env(:fcm) |> Enum.map(&(elem(&1, 0)))
  end

  def pools_by_mode(:apns, mode) do
    env(:apns)
    |> Enum.group_by(&(elem(&1, 1)[:mode]), &(elem &1, 0))
    |> Map.get(mode)
  end

  def env(var), do: Application.get_env(:mongoose_push, var)

end
