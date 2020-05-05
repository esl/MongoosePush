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
  alias MongoosePush.Service

  @typedoc "Available keys in `request` map"
  @type req_key ::
          :service
          | :mode
          | :alert
          | :data
          | :topic
          | :priority
          | :time_to_live
          | :mutable_content
  @type alert_key :: :title | :body | :tag | :badge | :click_action | :sound
  @type data_key :: atom | String.t()

  @typedoc "Raw push request. The keys: `:service` and at least one of `:alert` or `:body` are required"
  @type request :: %{req_key => atom | String.t() | integer | alert | data}
  @type alert :: %{alert_key => atom | String.t() | integer}
  @type data :: %{data_key => term}

  @type service :: :fcm | :apns
  @type mode :: :dev | :prod

  @type error :: {:generic, :no_matching_pool | :unable_to_connect | :connection_lost | atom}

  @doc """
  Push notification defined by `request` to device with `device_id`.
  `request` has to define at least `:service` type (`:fcm` or `:apns`) and
  at least one of `:alert` or `:data`. If `alert` is not present, the notification will be send as 'silent'.
  Please refer to yours push notification service provider's documentation for more details on
  silent notifications.

  Field `:data` may contain any custom data that have to be delivered to the target device, while
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
  @spec push(String.t(), request) ::
          :ok | {:error, Service.error()} | {:error, MongoosePush.error()}
  def push(device_id, %{:service => service} = request) do
    mode = Map.get(request, :mode, :prod)
    module = MongoosePush.Application.services()[service]
    tags = Map.get(request, :tags, [])
    pool = module.choose_pool(mode, tags)

    {time, push_result} =
      if pool == nil do
        Logger.error("Unable to choose pool",
          what: :pool_selection,
          result: :error,
          category: :generic,
          reason: :no_matching_pool,
          device_id: device_id,
          service: service,
          mode: mode,
          tags: tags
        )

        {0, {:error, {:generic, :no_matching_pool}}}
      else
        request =
          request
          |> Map.put(:alert, request[:alert])
          |> Map.put(:data, request[:data])

        notification = module.prepare_notification(device_id, request, pool)
        opts = [timeout: 60_000]

        :timer.tc(module, :push, [notification, device_id, pool, opts])
      end

    emit_telemetry_event(time, push_result, service, mode)

    maybe_log(push_result, device_id, request)
  end

  defp maybe_log(:ok, _device_id, _request), do: :ok

  defp maybe_log({:error, {category, reason}} = return_value, device_id, request) do
    %{:service => service} = request
    mode = Map.get(request, :mode, :prod)
    tags = Map.get(request, :tags, [])

    Logger.warn("Unable to send the push notification",
      what: :sending_notification,
      result: :error,
      category: category,
      reason: reason,
      device_id: device_id,
      service: service,
      mode: mode,
      tags: tags
    )

    return_value
  end

  defp maybe_log({:error, reason} = return_value, device_id, request) do
    %{:service => service} = request
    mode = Map.get(request, :mode, :prod)
    tags = Map.get(request, :tags, [])

    Logger.warn("Unable to send the push notification",
      what: :sending_notification,
      result: :error,
      category: :unknown,
      reason: reason,
      device_id: device_id,
      service: service,
      mode: mode,
      tags: tags
    )

    return_value
  end

  defp emit_telemetry_event(time, :ok, service, mode) do
    :telemetry.execute(
      [:mongoose_push, :push],
      %{time: time},
      %{
        status: :success,
        service: service,
        mode: mode
      }
    )
  end

  defp emit_telemetry_event(time, {:error, {type, reason}}, service, mode) do
    :telemetry.execute(
      [:mongoose_push, :push],
      %{time: time},
      %{
        status: :error,
        type: type,
        reason: reason,
        service: service,
        mode: mode
      }
    )
  end

  defp emit_telemetry_event(time, {:error, reason}, service, mode) do
    :telemetry.execute(
      [:mongoose_push, :push],
      %{time: time},
      %{
        status: :error,
        reason: reason,
        service: service,
        mode: mode
      }
    )
  end
end
