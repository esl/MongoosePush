defmodule MongoosePush.Metrics.TelemetryMetrics do
  @moduledoc """
  TODO
  """

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
    :ok
  end

  def handle_event(
        [:mongoose_push, :push, :count],
        measurements,
        metadata = %{:status => :error},
        _
      ) do
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
