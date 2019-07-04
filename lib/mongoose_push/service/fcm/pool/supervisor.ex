defmodule MongoosePush.Service.FCM.Pool.Supervisor do
  @moduledoc """
  This module is a basic FCM pool supervisor that has a list of active workers - temporary solution before migrating to Sparrow with its own supervisors
  """
  use Supervisor, id: :fcm_pool_supervisor
  require Logger
  alias MongoosePush.Application
  alias MongoosePush.Service.FCM.Pools

  @spec start_link([Application.pool_definition()]) :: Supervisor.on_start()
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  @impl true
  def init(pools_configs) do
    children =
      for {pool_name, pool_config} <- pools_configs do
        Logger.info(~s"Starting FCM pool with API key #{filter_secret(pool_config[:key])}")
        pool_size = pool_config[:pool_size]

        Enum.map(1..pool_size, fn id ->
          worker_name = Pools.worker_name(:fcm, pool_name, id)

          Supervisor.Spec.worker(
            Pigeon.GCMWorker,
            [worker_name, pool_config],
            id: worker_name
          )
        end)
      end

    list = List.flatten(children)
    Supervisor.init(list, strategy: :one_for_one)
  end

  defp filter_secret(secret) when is_binary(secret) do
    prefix = String.slice(secret, 0..2)

    suffix =
      secret
      |> String.slice(3..-1)
      |> String.slice(-3..-1)

    prefix <> "*******" <> suffix
  end

  defp filter_secret(secret), do: secret
end
