defmodule MongoosePush.Service.FCM do
  @moduledoc """
  FCM (Firebase Cloud Messaging) service provider implementation.
  """

  @behaviour MongoosePush.Service
  alias Pigeon.GCM
  alias Pigeon.GCM.Notification
  alias MongoosePush.{Application, Service}
  alias MongoosePush.Service.FCM.Pools
  alias MongoosePush.Service.FCM.Pool.Supervisor, as: PoolSupervisor
  require Logger

  @priority_mapping %{normal: "normal", high: "high"}

  @spec prepare_notification(String.t(), MongoosePush.request(), atom()) ::
          Service.notification()
  def prepare_notification(device_id, %{alert: nil} = request, _pool) do
    # Setup silent notification
    Notification.new(device_id, nil, request[:data])
    |> Notification.put_ttl(request[:time_to_live])
    |> Notification.put_priority(@priority_mapping[request[:priority]])
  end

  def prepare_notification(device_id, request, _pool) do
    # Setup non-silent notification
    alert = request.alert

    msg =
      [:body, :title, :click_action, :tag, :sound]
      |> Enum.reduce(%{}, fn field, map ->
        Map.put(map, field, alert[field])
      end)

    Notification.new(device_id, msg, request[:data])
    |> Notification.put_priority(@priority_mapping[request[:priority]])
    |> Notification.put_ttl(request[:time_to_live])
  end

  @spec push(Service.notification(), String.t(), atom(), Service.options()) ::
          :ok | {:error, term}
  def push(notification, device_id, _pool, opts \\ []) do
    worker = Pools.select_worker()

    case GCM.push(notification, Keyword.merge([name: worker], opts)) do
      {:ok, state} ->
        %Pigeon.GCM.NotificationResponse{ok: ok, update: update} = state

        case Enum.member?(ok ++ update, device_id) do
          true ->
            :ok

          false ->
            {:error, :invalid_device_token}
        end

      {:error, reason, _state} ->
        {:error, reason}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec supervisor_entry([Application.pool_definition()] | nil) :: {module(), term()}
  def supervisor_entry(pools_configs) do
    {PoolSupervisor, pools_configs}
  end

  @spec choose_pool(MongoosePush.mode()) :: Application.pool_name() | nil
  def choose_pool(_mode) do
    [pool | _] = Pools.pools_by_mode()
    pool
  end
end
