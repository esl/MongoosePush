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

  @behaviour MongoosePush.Notification

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
          | :tags
  @type alert_key :: :title | :body | :tag | :badge | :click_action | :sound
  @type data_key :: atom | String.t()

  @typedoc "Raw push request. `:service` and at least one of `:alert` or `:data` are required."
  @type request :: %{req_key => atom | String.t() | integer | alert | data}
  @type alert :: %{alert_key => atom | String.t() | integer}
  @type data :: %{data_key => term}

  @type service :: :fcm | :apns
  @type mode :: :dev | :prod

  @type error :: {:generic, :no_matching_pool | :unable_to_connect | :connection_lost | atom}

  @doc """
  Push notification defined by `request` to device with `device_id`.
  The request requires `:service` (`:fcm` or `:apns`) and at least one of
  `:alert` or `:data`. Without `:alert`, the notification is silent.

  `:data` contains application-specific key-value data. In a data-only request,
  `%{"type" => "jmi"}` identifies a Jingle Message Initiation call notification.
  FCM derives its collapse key from a non-empty `"jmi-sid"`. For APNS, this creates
  a VoIP notification and requires a PushKit token and a `.voip` topic.

  An `:alert` requires `:title` and `:body` and may include `:sound`,
  `:click_action`, `:tag` (FCM), or `:badge` (APNS).

  `:priority` accepts `:normal` or `:high`; APNS maps them to `"5"` and `"10"`.

  `:mode` selects the `:prod` (default) or `:dev` pool.

  `:mutable_content` enables the corresponding APS option for non-JMI notifications.
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

    Logger.warning("Unable to send the push notification",
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

    Logger.warning("Unable to send the push notification",
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
      [:mongoose_push, :notification, :send],
      %{time: time},
      %{
        status: :success,
        service: service,
        mode: mode,
        error_category: nil,
        error_reason: nil
      }
    )
  end

  defp emit_telemetry_event(time, {:error, {type, reason}}, service, mode) do
    :telemetry.execute(
      [:mongoose_push, :notification, :send],
      %{time: time},
      %{
        status: :error,
        error_category: type,
        error_reason: reason,
        service: service,
        mode: mode
      }
    )
  end

  defp emit_telemetry_event(time, {:error, reason}, service, mode) do
    :telemetry.execute(
      [:mongoose_push, :notification, :send],
      %{time: time},
      %{
        status: :error,
        error_category: :generic,
        error_reason: reason,
        service: service,
        mode: mode
      }
    )
  end
end
