defmodule MongoosePush.Telemetry.FCMHandler do
  @moduledoc """
  Module responsible for handling FCM telemetry events
  """
  alias MongoosePush.Metrics
  use Metrics

  @behaviour MongoosePush.Telemetry

  def event_names do
    [
      [:mongoose_push, :fcm, :push, :success],
      [:mongoose_push, :fcm, :push, :error],
      [:mongoose_push, :fcm, :supervisor, :init]
    ]
  end

  def handle_event([:mongoose_push, :fcm, :push, :success], measurements, metadata, _) do
    Metrics.update_success(:ok, :spiral, [:push, metadata.service, metadata.mode])

    Metrics.update_success(
      :ok,
      :timer,
      [:push, metadata.service, metadata.mode],
      measurements.time
    )

    Metrics.update_metric(:timer, "mongoose_push.push", measurements.time)

    :ok
  end

  def handle_event([:mongoose_push, :fcm, :push, :error], measurements, metadata, _) do
    type = Map.get(metadata, :type)

    push_result =
      case type do
        nil ->
          {:error, metadata.reason}

        _ ->
          {:error, {type, metadata.reason}}
      end

    push_result
    |> Metrics.update_error(:spiral, [:push, metadata.service, metadata.mode])
    |> Metrics.update_error(:timer, [:push, metadata.service, metadata.mode], measurements.time)

    Metrics.update_metric(:timer, "mongoose_push.push", measurements.time)

    :ok
  end

  def handle_event([:mongoose_push, :fcm, :supervisor, :init], _, _, _) do
    :ok
  end
end
