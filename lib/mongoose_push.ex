defmodule MongoosePush do
  @moduledoc """
  MongoosePush is simple (seriously) service providing ability to send push
  notification to `FCM` (Firebase Cloud Messaging) and/or
  `APNS` (Apple Push Notification Service). What makes it cool is not only
  simplicity but also support for newest and fastest `HTTP/2` based APIs
  for both services.

  At this moment only those two services are supported but in future
  MongoosePush may and probably will support even more Push Notification Services.
  """

  require Logger
  import MongoosePush.Application
  alias Pigeon.GCM
  alias Pigeon.APNS

  @typedoc "Available keys in `request` map"
  @type req_key :: :service | :body | :title | :bagde | :mode | :tag |
                   :topic | :click_action

  @typedoc "Raw push request. The keys: `:service`, `:body` and `:title` are required"
  @type request :: %{req_key => atom | String.t | integer}

  @type service :: :fcm | :apns
  @type mode :: :dev | :prod

  @doc """
  Push notification defined by `request` to device with `device_id`.
  `request` has to define at least `:service` type (`:fcm` or `:apns`) and
  both message `:title` and its `:body`.

  `:tag` is option
  specific to FCM service, while `:topic` and `:bagde` are specific to APNS
  (please consult their API for more informations).

  `:mode` option is also specific to APNS but it only selects appropriate
  worker pool (with `:mode` set to either `:prod` or `:dev`).
  Default value to `:mode` is `:prod`.
  """
  @spec push(String.t, request) :: :ok | {:error, term}
  def push(device_id, %{:service => service} = request) do
      mode = Map.get(request, :mode, :prod)
      [pool | _] = pools_by_mode(service, mode)
      worker = worker_name(service, pool,
                           Enum.random(1..pool_size(service, pool)))

      push(service, worker, device_id, request)
  end

  @spec push(service, atom | pid, String.t, request) :: :ok | {:error, term}
  defp push(:fcm, worker, device_id, request) do
    msg = prepare_notification(:fcm, request)
    gcm_notification = Pigeon.GCM.Notification.new(device_id, msg)

    gcm_notification
    |> GCM.push([name: worker])
    |> normalize_response(:fcm, device_id)
  end

  @spec push(service, atom | pid, String.t, request) :: :ok | {:error, term}
  defp push(:apns, worker, device_id, request) do
    raw_notification = prepare_notification(:apns, request)

    raw_notification
    |> APNS.Notification.new(device_id, request[:topic])
    |> APNS.push([name: worker])
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
