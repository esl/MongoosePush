[
  # Prometheus Core incorrectly defines its specs, not admiting the `metrics:` tag:
  # https://github.com/beam-telemetry/telemetry_metrics_prometheus_core/issues/20
  ~r/lib\/mongoose_push\/metrics\/telemetry_metrics\.ex.*child_spec.*no local return/,
  ~r/lib\/mongoose_push\/metrics\/telemetry_metrics\.ex.*child_spec.*will not succeed/,
  ~r/unmatched_return/,
  ~r/Function :asn1ct.compile\/2 does not exist/,
  ~r/lib\/mix\//,
  {"lib/mongoose_push/router.ex"},
  {"test/support/api.ex"}
]
