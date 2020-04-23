defmodule MongoosePush.Service.FCM do
  @moduledoc """
  FCM (Firebase Cloud Messaging) service provider implementation.
  """

  @behaviour MongoosePush.Service
  alias Sparrow.FCM.V1, as: FCM
  alias Sparrow.FCM.V1.Notification
  alias Sparrow.FCM.V1.Android
  alias MongoosePush.Application
  alias MongoosePush.Service
  alias MongoosePush.Service.FCM.Pool.Supervisor, as: PoolSupervisor
  alias MongoosePush.Service.FCM.ErrorHandler
  require Logger

  @priority_mapping %{normal: :NORMAL, high: :HIGH}

  @spec prepare_notification(String.t(), MongoosePush.request(), atom()) ::
          Service.notification()
  def prepare_notification(device_id, %{alert: nil} = request, _pool) do
    # Setup silent notification
    android =
      Android.new()
      |> maybe(:add_priority, @priority_mapping[request[:priority]])
      |> maybe(:add_ttl, request[:time_to_live])
      |> maybe(:add_data, request[:data])

    Notification.new(:token, device_id)
    |> Notification.add_android(android)
  end

  def prepare_notification(device_id, request, _pool) do
    # Setup non-silent notification
    alert = request.alert



    android =
      Android.new()
      |> Android.add_title(alert.title)
      |> Android.add_body(alert.body)
      |> maybe(:add_priority, @priority_mapping[request[:priority]])
      |> maybe(:add_ttl, request[:time_to_live])
      |> maybe(:add_data, request[:data])
      |> maybe(:add_click_action, alert[:click_action])
      |> maybe(:add_tag, alert[:tag])
      |> maybe(:add_sound, alert[:sound])

      IO.inspect(android)

    Notification.new(:token, device_id)
    |> Notification.add_android(android)
  end

  @spec push(Service.notification(), String.t(), Application.pool_name(), Service.options()) ::
          :ok | {:error, Service.error()} | {:error, MongoosePush.error()}
  def push(notification, _device_id, pool, _opts \\ []) do
    case FCM.push(pool, notification, is_sync: true) do
      :ok ->
        :ok

      {:error, reason} ->
        {:error, unify_error(reason)}
    end
  end

  @spec supervisor_entry([Application.pool_definition()] | nil) :: {module(), term()}
  def supervisor_entry(pools_configs) do
    {PoolSupervisor, pools_configs}
  end

  @spec choose_pool(MongoosePush.mode(), [any]) :: Application.pool_name() | nil
  def choose_pool(mode, tags \\ []) do
    Sparrow.PoolsWarden.choose_pool(:fcm, [mode | tags])
  end

  defp maybe(notification, _function, nil), do: notification
  defp maybe(notification, function, arg), do: apply(Android, function, [notification, arg])

  @spec unify_error(Service.error_reason()) :: Service.error() | MongoosePush.error()
  def unify_error(reason) do
    {type, reason_} = ErrorHandler.translate_error_reason(reason)

    case type do
      :unknown ->
        {:generic, reason_}

      _ ->
        {type, reason_}
    end
  end
end
