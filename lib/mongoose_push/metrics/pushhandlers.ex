defmodule MongoosePush.Metrics.PushHandlers do
  @moduledoc """
  TODO
  """
  alias MongoosePush.Metrics.Exometer, as: Metrics

  @behaviour MongoosePush.Telemetry

  def event_names do
    [
      [:mongoose_push, :push, :count],
      [:mongoose_push, :supervisor, :init],
      [:mongoose_push, :apns, :state, :init],
      [:mongoose_push, :apns, :state, :terminate],
      [:mongoose_push, :apns, :state, :get_default_topic]
    ]
  end

  def handle_event(
        [:mongoose_push, :push, :count],
        measurements,
        metadata = %{:status => :success},
        _
      ) do
    Metrics.update_success(:spiral, [:push, metadata.service, metadata.mode])

    Metrics.update_success(
      :timer,
      [:push, metadata.service, metadata.mode],
      measurements.time
    )

    Metrics.update_metric(:timer, "mongoose_push.push", measurements.time)

    :ok
  end

  def handle_event(
        [:mongoose_push, :push, :count],
        measurements,
        metadata = %{:status => :error},
        _
      ) do
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

  def handle_event([:mongoose_push, :apns, :state, :init], _, _, _) do
    :ok
  end

  def handle_event([:mongoose_push, :apns, :state, :terminate], _, _, _) do
    :ok
  end

  def handle_event([:mongoose_push, :apns, :state, :get_default_topic], _, _, _) do
    :ok
  end

  def handle_event([:mongoose_push, :supervisor, :init], _, _, _) do
    :ok
  end
end
