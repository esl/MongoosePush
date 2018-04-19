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
  alias MongoosePush.Pools
  alias MongoosePush.Metrics
  use Metrics

  @typedoc "Available keys in `request` map"
  @type req_key :: :service | :mode | :alert | :data | :topic | :priority
  @type alert_key :: :title | :body | :tag | :badge | :click_action | :sound
  @type data_key :: atom | String.t

  @typedoc "Raw push request. The keys: `:service` and at least one of `:alert` or `:body` are required"
  @type request :: %{req_key => atom | String.t | integer | alert | data}
  @type alert :: %{alert_key => atom | String.t | integer}
  @type data :: %{data_key => term}

  @type service :: :fcm | :apns
  @type mode :: :dev | :prod

  @doc """
  Push notification defined by `request` to device with `device_id`.
  `request` has to define at least `:service` type (`:fcm` or `:apns`) and
  at least one of `:alert` or `:data`. If `alert` is not present, the notification will be send as 'silent'.
  Please refer to yours push notification service provider's documentation for more details on
  silent notifications.

  Field `:data` may conatin any custom data that have to be delivered to the target device, while
  field `:alert`, if present, must contain at least `:title` and `:body`. The `:alert` field may also
  contain: :sound, `:tag` (option specific to FCM service), `:topic` and `:bagde` (specific to APNS).
  Please consult push notification service provider's documentation for more informations on those
  optional fields.

  Field `:priority` may be used to set priority for message on both FCM and APNS. The values are
  native for FCM and for APNS - :normal is "5" and :high is 10.

  `:mode` option is also specific to APNS but it only selects appropriate
  worker pool (with `:mode` set to either `:prod` or `:dev`).
  Default value to `:mode` is `:prod`.

  Field `:mutable_content` (specific to APNS) can be set to `true` (by default `false`) to enable
  this feature (please consult APNS documentation for more information).
  """
  @timed(key: :auto)
  @spec push(String.t, request) :: :ok | {:error, term}
  def push(device_id, %{:service => service} = request) do
      mode = Map.get(request, :mode, :prod)
      worker = Pools.select_worker(service, mode)
      module = MongoosePush.Application.services()[service]

      # Just make sure both data and alert keys exist for convenience (but may be nil)
      request =
        request
        |> Map.put(:alert, request[:alert])
        |> Map.put(:data, request[:data])

      notification = module.prepare_notification(device_id, request)
      opts = [timeout: 60_000]
      {time, push_result} = :timer.tc(module, :push, [notification, device_id, worker, opts])

      push_result
      |> Metrics.update(:spiral, [:push, service, mode])
      |> Metrics.update(:timer, [:push, service, mode], time)
      |> maybe_log
  end

  defp maybe_log(:ok), do: :ok
  defp maybe_log({:error, reason} = return_value) when is_atom(reason) do
    Logger.warn ~s"Unable to complete push request due to #{reason}"
    return_value
  end
  defp maybe_log({:error, reason} = return_value) do
    Logger.warn ~s"Unable to complete push request due to unknown error: " <>
                ~s"#{inspect reason}"
    return_value
  end

end
