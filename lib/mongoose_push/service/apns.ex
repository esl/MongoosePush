defmodule MongoosePush.Service.APNS do
  @moduledoc """
  APNS (apple Push Notification Service) service provider implementation.
  """

  @behaviour MongoosePush.Service
  require Logger
  alias Sparrow.APNS
  alias Sparrow.APNS.Notification
  alias MongoosePush.Application
  alias MongoosePush.Service
  alias MongoosePush.Service.APNS.State
  alias MongoosePush.Service.APNS.ErrorHandler

  @priority_mapping %{normal: "5", high: "10"}

  @spec prepare_notification(String.t(), MongoosePush.request(), atom()) ::
          Service.notification()
  def prepare_notification(device_id, %{alert: nil} = request, _pool) do
    # Setup silent notification
    Notification.new(device_id, Map.get(request, :mode, :prod))
    |> Notification.add_content_available(1)
    |> maybe(:add_apns_topic, request[:topic])
    |> maybe(:add_mutable_content, request[:mutable_content])
    |> maybe(:add_apns_priority, @priority_mapping[request[:priority]])
    |> add_data(request[:data])
  end

  def prepare_notification(device_id, request, pool) do
    # Setup non-silent notification
    alert = request.alert
    default_topic = State.get_default_topic(pool)

    Notification.new(device_id, Map.get(request, :mode, :prod))
    |> Notification.add_title(alert.title)
    |> Notification.add_body(alert.body)
    |> maybe(:add_apns_topic, request[:topic] || default_topic)
    |> maybe(:add_mutable_content, request[:mutable_content])
    |> maybe(:add_apns_priority, @priority_mapping[request[:priority]])
    |> maybe(:add_badge, alert[:badge])
    |> maybe(:add_category, alert[:click_action])
    |> maybe(:add_sound, alert[:sound])
    |> add_data(request[:data])
  end

  @spec push(Service.notification(), String.t(), Application.pool_name(), Service.options()) ::
          :ok | {:error, Service.error()}
  def push(notification, _device_id, pool, _opts \\ []) do
    case APNS.push(pool, notification, is_sync: true) do
      :ok ->
        :ok

      {:error, reason} ->
        {:error, unify_error(reason)}
    end
  end

  @spec supervisor_entry([Application.pool_definition()] | nil) :: {module(), term()}
  def supervisor_entry(pool_configs) do
    {MongoosePush.Service.APNS.Supervisor, pool_configs}
  end

  @spec choose_pool(MongoosePush.mode(), [any]) :: Application.pool_name() | nil
  def choose_pool(mode, tags \\ []) do
    Sparrow.PoolsWarden.choose_pool({:apns, mode}, tags)
  end

  @spec unify_error(Service.error_reason()) :: Service.error()
  def unify_error(reason) do
    ErrorHandler.translate_error_reason(reason)
  end

  defp maybe(notification, :add_mutable_content, true),
    do: apply(Notification, :add_mutable_content, [notification])

  defp maybe(notification, :add_mutable_content, _), do: notification
  defp maybe(notification, _function, nil), do: notification
  defp maybe(notification, function, arg), do: apply(Notification, function, [notification, arg])

  defp add_data(notification, arg) do
    List.foldl(Map.keys(arg || %{}), notification, fn key, notification ->
      Notification.add_custom_data(notification, key, arg[key])
    end)
  end
end
