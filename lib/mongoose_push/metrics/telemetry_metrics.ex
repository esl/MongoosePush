defmodule MongoosePush.Metrics.TelemetryMetrics do
  @moduledoc """
  Module responsible for updating `Telemetry` metrics
  """

  def child_spec(_) do
    TelemetryMetricsPrometheus.Core.child_spec(metrics: metrics())
  end

  def metrics do
    [
      # Summary is not yet supported in TelemetryMetricsPrometheus
      Telemetry.Metrics.distribution("mongoose_push.notification.send.time",
        buckets: [100, 250, 500, 1000],
        tags: [:status, :service, :error_category, :error_reason],
        unit: {:native, :second}
      ),

      # measurement is ignored in Counter metric
      Telemetry.Metrics.counter("mongoose_push.supervisor.init.count", tags: [:service]),
      Telemetry.Metrics.counter("mongoose_push.apns.state.init.count"),
      Telemetry.Metrics.counter("mongoose_push.apns.state.terminate.count",
        tags: [:error_reason],
        tag_values: fn metadata -> %{metadata | error_reason: metadata.reason} end
      ),
      Telemetry.Metrics.counter("mongoose_push.apns.state.get_default_topic.count")
    ]
  end
end
