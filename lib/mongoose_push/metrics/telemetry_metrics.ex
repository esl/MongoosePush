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
      ),

      # Sparrow events
      distribution(
        "sparrow.h2_worker.handle.duration.microsecond",
        event_name: [:sparrow, :h2_worker, :handle],
        measurement: :time,
        reporter_options: [
          buckets: [10_000, 25_000, 50_000, 100_000, 200_000, 500_000, 1000_000]
        ],
        description: "A histogram showing time it takes for h2_worker to handle request."
      ),
      counter("sparrow.h2_worker.init.count",
        event_name: [:sparrow, :h2_worker, :init],
        description: "Counts the number of h2_worker starts."
      ),
      counter("sparrow.h2_worker.terminate.count",
        event_name: [:sparrow, :h2_worker, :terminate],
        description: "Counts the number of h2_worker terminations."
      ),
      counter("sparrow.h2_worker.conn_success.count",
        event_name: [:sparrow, :h2_worker, :conn_success],
        description: "Counts the number of successful h2_worker connections."
      ),
      counter("sparrow.h2_worker.conn_fail.count",
        event_name: [:sparrow, :h2_worker, :conn_fail],
        description: "Counts the number of failed h2_worker connections."
      ),
      counter("sparrow.h2_worker.conn_lost.count",
        event_name: [:sparrow, :h2_worker, :conn_lost],
        description: "Counts the number of lost h2_worker connections."
      ),
      counter("sparrow.h2_worker.request_success.count",
        event_name: [:sparrow, :h2_worker, :request_success],
        description: "Counts the number of successful h2_worker requests."
      ),
      counter("sparrow.h2_worker.request_error.count",
        event_name: [:sparrow, :h2_worker, :request_error],
        description: "Counts the number of failed h2_worker requests."
      ),
      # Telemetry Poller metrics
      last_value(
        "sparrow.pools_warden.workers.gauge",
        event_name: [:sparrow, :pools_warden, :workers],
        measurement: :count,
        tags: [:pool],
        description: "Total count of workers handled by worker_pool."
      ),
      last_value(
        "sparrow.pools_warden.pools.gauge",
        event_name: [:sparrow, :pools_warden, :pools],
        measurement: :count,
        description: "Total count of the connection pools."
      ),
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
    stats = :wpool.stats()

    Enum.map(stats, fn stat ->
      :telemetry.execute(
        [:sparrow, :pools_warden, :workers],
        %{count: length(stat[:workers])},
        %{pool: stat[:pool]}
      )
    end)

    :telemetry.execute(
      [:sparrow, :pools_warden, :pools],
      %{count: length(stats)},
      %{}
    )
  end
end
