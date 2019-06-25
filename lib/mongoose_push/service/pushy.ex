defmodule MongoosePush.Service.Pushy do
  @moduledoc """
  Pushy service provider implementation.
  """

  @behaviour MongoosePush.Service
  alias MongoosePush.Pools
  require Logger

  @spec prepare_notification(String.t(), MongoosePush.request) ::
    Service.notification
  def prepare_notification(device_id, request) do
    MongoosePush.Service.FCM.prepare_notification(device_id, request)
  end

  @spec push(Service.notification(), String.t(), atom(), Service.options()) ::
    :ok | {:error, term}
  def push(notification, device_id, worker, opts \\ []) do
    MongoosePush.Service.FCM.push(notification, device_id, worker, opts)
  end

  @spec workers({atom, Keyword.t()} | nil) :: list(Supervisor.Spec.spec())
  def workers(nil), do: []
  def workers({pool_name, pool_config}) do
    Logger.info ~s"Starting Pushy pool with API key #{filter_secret(pool_config[:key])}"
    pool_size = pool_config[:pool_size]
    Enum.map(1..pool_size, fn(id) ->
      worker_name = Pools.worker_name(:pushy, pool_name, id)
      Supervisor.Spec.worker(Pigeon.PushyWorker,
                             [worker_name, pool_config], [id: worker_name])
    end)
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
