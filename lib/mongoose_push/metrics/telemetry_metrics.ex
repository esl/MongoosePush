defmodule MongoosePush.Metrics.TelemetryMetrics do
  @moduledoc """
  Module responsible for updating `Telemetry` metrics
  """
  import Telemetry.Metrics

  def child_spec(_) do
    TelemetryMetricsPrometheus.Core.child_spec(metrics: metrics())
  end

  def pooler do
    [{:telemetry_poller, measurements: periodic_measurements(), period: 30_000}]
  end

  def metrics do
    [
      # Summary is not yet supported in TelemetryMetricsPrometheus
      distribution(
        "mongoose_push.notification.send.time.microsecond",
        event_name: [:mongoose_push, :notification, :send],
        measurement: :time,
        reporter_options: [
          buckets: [1000, 10_000, 25_000, 50_000, 100_000, 250_000, 500_000, 1000_000]
        ],
        tags: [:status, :service, :error_category, :error_reason],
        description:
          "A histogram showing push notification send times. Includes worker selection (with possible waiting if all are busy)"
      ),

      # Measurement is ignored in Counter metric
      counter("mongoose_push.supervisor.init.count",
        tags: [:service],
        description: "Counts the number of push notification service supervisor starts"
      ),
      counter("mongoose_push.apns.state.init.count",
        description: "Counts the number of APNS state initialisations"
      ),
      counter("mongoose_push.apns.state.terminate.count",
        tags: [:error_reason],
        tag_values: fn metadata -> %{metadata | error_reason: metadata.reason} end,
        description: "Counts the number of APNS state terminations"
      ),
      counter("mongoose_push.apns.state.get_default_topic.count",
        description: "Counts the number of APNS default topic reads from the ETS cache"
      )
    ] ++ sparrow_metrics() ++ vm_metrics()
  end

  defp sparrow_metrics do
    [
      # Sparrow events
      counter("sparrow.pool.request.count",
        event_name: [:sparrow, :pool, :request],
        tags: [:pool, :result, :reason, :status],
        tag_values: &__MODULE__.sparrow_tags/1,
        description:
          "Counts the number of requests sent to push notification services, with their results."
      ),
      distribution(
        "sparrow.pool.request.duration.microsecond",
        event_name: [:sparrow, :pool, :request],
        measurement: :time,
        tags: [:pool, :result],
        tag_values: &__MODULE__.sparrow_tags/1,
        reporter_options: [
          buckets: [10_000, 25_000, 50_000, 100_000, 200_000, 500_000, 1000_000]
        ],
        description: "A histogram showing time it takes to send request and receive response."
      ),
      counter("sparrow.pool.retry.count",
        event_name: [:sparrow, :pool, :retry],
        tags: [:pool, :reason],
        tag_values: &__MODULE__.sparrow_tags/1,
        description:
          "Counts the number of requests which were not sent at the first attempt and had to be sent again."
      ),
      counter("sparrow.pool.connect.count",
        event_name: [:sparrow, :pool, :connect],
        tags: [:pool, :result, :reason],
        tag_values: &__MODULE__.sparrow_tags/1,
        description:
          "Counts the number of attempts to connect to push notification services, with their results."
      ),
      distribution(
        "sparrow.pool.connect.duration.microsecond",
        event_name: [:sparrow, :pool, :connect],
        measurement: :time,
        tags: [:pool, :result],
        tag_values: &__MODULE__.sparrow_tags/1,
        reporter_options: [
          buckets: [10_000, 25_000, 50_000, 100_000, 250_000, 500_000, 1000_000, 5000_000]
        ],
        description:
          "A histogram showing time it takes to connect to a push notification service."
      ),
      # Telemetry Poller metrics
      last_value(
        "sparrow.pool.connections.gauge",
        event_name: [:mongoose_push, :sparrow, :pool],
        measurement: :connections,
        tags: [:pool],
        description: "Number of connections the pool is configured to keep."
      ),
      last_value(
        "sparrow.pool.connected.gauge",
        event_name: [:mongoose_push, :sparrow, :pool],
        measurement: :connected,
        tags: [:pool],
        description: "Number of currently established connections of the pool."
      )
    ]
  end

  defp vm_metrics do
    [
      # Default Telemetry Poller VM metrics
      last_value(
        "vm.memory.total",
        unit: :byte,
        description: "Total amount of currently allocated memory."
      ),
      last_value(
        "vm.memory.processes",
        unit: :byte,
        description: "Amount of memory currently allocated for processes."
      ),
      last_value(
        "vm.memory.processes_used",
        unit: :byte,
        description: "Amount of memory currently used for processes."
      ),
      last_value(
        "vm.memory.binary",
        unit: :byte,
        description: "Amount of memory currently allocated for binaries."
      ),
      last_value(
        "vm.memory.ets",
        unit: :byte,
        description: "Amount of memory currently allocated for ETS tables."
      ),
      last_value(
        "vm.total_run_queue_lengths.total",
        description: "A sum of all current run queue lengths."
      ),
      last_value(
        "vm.total_run_queue_lengths.cpu",
        description: "A sum of current CPU schedulers' run queue lengths."
      ),
      last_value(
        "vm.system_counts.process_count",
        description: "Number of process currently existing at the local node."
      )
    ]
  end

  def periodic_measurements do
    [
      {MongoosePush.Metrics.TelemetryMetrics, :running_pools, []}
    ]
  end

  def running_pools do
    Enum.each(Sparrow.Pool.stats(), fn stat ->
      :telemetry.execute(
        [:mongoose_push, :sparrow, :pool],
        %{connections: stat.connections, connected: stat.connected},
        %{pool: stat.pool}
      )
    end)
  end

  @doc false
  # Tags of Sparrow pool events. The values which are not in the event are empty.
  def sparrow_tags(metadata) do
    %{
      pool: metadata.pool_name,
      result: metadata[:result],
      reason: reason_tag(metadata[:reason]),
      status: metadata[:status]
    }
  end

  # Details of the reason are skipped to keep the number of time series low
  defp reason_tag(reason) when is_atom(reason), do: reason
  defp reason_tag({reason, _details}) when is_atom(reason), do: reason
  defp reason_tag(_reason), do: :other
end
