defmodule MongoosePush.Service.FCM do
  @moduledoc """
  FCM (Firebase Cloud Messaging) service provider implementation.
  """

  @behaviour MongoosePush.Service
  alias Pigeon.GCM

  @spec prepare_notification(string, MongoosePush.request) ::
    Service.notification
  def prepare_notification(device_id, request) do
    msg = [:body, :title, :click_action, :tag]
    |> Enum.reduce(%{}, fn(field, map) ->
      Map.put(map, field, request[field])
    end)
    Pigeon.GCM.Notification.new(device_id, msg)
  end

  @spec push(Service.notification, string, atom) :: :ok | {:error, term}
  def push(notification, device_id, worker) do
    case GCM.push(notification, [name: worker]) do
      {:ok, state} ->
        %Pigeon.GCM.NotificationResponse{ok: ok, update: update} = state
        case Enum.member?(ok ++ update, device_id) do
          true -> :ok
          false ->
            {:error, :invalid_device_token}
        end
      {:error, reason, _state} ->
        {:error, reason}
    end
  end

end
