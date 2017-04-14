defmodule MongoosePush.Service.FCM do
  @moduledoc """
  FCM (Firebase Cloud Messaging) service provider implementation.
  """

  @behaviour MongoosePush.Service
  alias Pigeon.GCM
  alias Pigeon.GCM.Notification
  alias MongoosePush.Pools
  require Logger

  @spec prepare_notification(String.t(), MongoosePush.request) ::
    Service.notification
  def prepare_notification(device_id, request) do
    msg = [:body, :title, :click_action, :tag]
    |> Enum.reduce(%{}, fn(field, map) ->
      Map.put(map, field, request[field])
    end)
    Notification.new(device_id, msg, request[:data])
  end

  @spec push(Service.notification(), String.t(), atom(), Service.options()) ::
    :ok | {:error, term}
  def push(notification, device_id, worker, opts \\ []) do
    case GCM.push(notification, Keyword.merge([name: worker], opts)) do
      {:ok, state} ->
        %Pigeon.GCM.NotificationResponse{ok: ok, update: update} = state
        case Enum.member?(ok ++ update, device_id) do
          true -> :ok
          false ->
            {:error, :invalid_device_token}
        end
      {:error, reason, _state} ->
        {:error, reason}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec workers({atom, Keyword.t()} | nil) :: list(Supervisor.Spec.spec())
  def workers(nil), do: []
  def workers({pool_name, pool_config}) do
    Logger.info ~s"Starting FCM pool with API key #{pool_config[:key]}"
    pool_size = pool_config[:pool_size]
    Enum.map(1..pool_size, fn(id) ->
      worker_name = Pools.worker_name(:fcm, pool_name, id)
      Supervisor.Spec.worker(Pigeon.GCMWorker,
                             [worker_name, pool_config], [id: worker_name])
    end)
  end

end
