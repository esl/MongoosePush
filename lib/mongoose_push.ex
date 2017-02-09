defmodule MongoosePush do
  @moduledoc """
  Documentation for MongoosePush.
  """

  require Logger
  import MongoosePush.Application

  def push(device_id, %{:service => service} = request) do
      mode = Map.get(request, :mode, :prod)
      [pool | _] = pools_by_mode(service, mode)
      worker = worker_name(service, pool,
                           Enum.random(1..pool_size(service, pool)))

      push(service, worker, device_id, request)
  end

  def push(:fcm, worker, device_id, request) do
    msg = prepare_notification(:fcm, request)
    Pigeon.GCM.Notification.new(device_id, msg)
    |> Pigeon.GCM.push([name: worker])
    |> normalize_response(:fcm, device_id)
  end

  def push(:apns, worker, device_id, request) do
    prepare_notification(:apns, request)
    |> Pigeon.APNS.Notification.new(device_id, request[:topic])
    |> Pigeon.APNS.push([name: worker])
    |> normalize_response(:apns, device_id)
  end

  defp normalize_response(:ok, _, _), do: :ok
  defp normalize_response({:error, reason, _state}, _, _) do
    {:error, reason}
  end

  defp normalize_response({:ok, state}, :fcm, device_id) do
    %Pigeon.GCM.NotificationResponse{ok: ok, update: update} = state
    case Enum.member?(ok ++ update, device_id) do
      true -> :ok
      false ->
        {:error, :invalid_device_token}
    end
  end

  defp normalize_response({:ok, _state}, :apns, _device_id), do: :ok

  defp prepare_notification(:fcm, request) do
    Logger.warn inspect request
    [:body, :title, :click_action, :tag]
    |> Enum.reduce(%{}, fn(field, map) ->
      Map.put(map, field, request[field])
    end)
  end

  defp prepare_notification(:apns, request) do
    %{
      "alert" => %{
        "title" => request.title,
        "body" => request.body
      },
      "badge" => request[:badge],
      "category" => request[:click_action]
    }
  end

end
