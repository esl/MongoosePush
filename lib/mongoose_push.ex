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
  use Elixometer

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
  @timed(key: :auto)
  @spec push(String.t, request) :: :ok | {:error, term}
  def push(device_id, %{:service => service} = request) do
      mode = Map.get(request, :mode, :prod)
      worker = Pools.select_worker(service, mode)
      module = MongoosePush.Application.services()[service]

      notification = module.prepare_notification(device_id, request)
      opts = [timeout: 60_000]
      push_result = module.push(notification, device_id, worker, opts)

      push_result
      |> Metrics.update(~s"push.#{service}.#{mode}")
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
