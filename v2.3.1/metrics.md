# Metrics

MongoosePush 2.1 provides metrics in the Prometheus format on the `/metrics` endpoint.
This is a breaking change compared to previous releases.
Existing dashboards will need to be updated.

It is important to know that metrics are created inside MongoosePush only when a certain event happens.
This may mean that a freshly started MongoosePush node will not have all the possible metrics available yet.

## Default dashboard

MongoosePush 2.1.1 provides default Grafana dashboards where we can see some of the available metrics.
You can create the dashboards using the following command:

```bash
make dashboards
```

This starts and configures two containers:
* `mpush-grafana` - running Grafana, available at http://127.0.0.1:3000/
* `mpush-prometheus` - running Prometheus, which scraps the metrics from the `/metrics` endpoint, available at http://127.0.0.1:9090/

Once we login to the Grafana container with the default (login: admin, password: admin) credentials we can see two dashboards:
* MongoosePush Metrics - displaying metrics related to notification send times and successful/failed connections.
* MongoosePush VM - this dashboard contains metrics related to the VM like memory allocations or lengths of the run queues.

You can stop the docker containers that are running Grafana and Prometheus using the following command:

```bash
make clean-dashboards
```

## Available metrics

#### Histograms

For more details about the histogram metric type please go to https://prometheus.io/docs/concepts/metric_types/#histogram

###### Notification sent time

`mongoose_push_notification_send_time_microsecond_bucket{error_category=${CATEGORY},error_reason=${REASON},service=${SERVICE},status=${STATUS},le=${LE}}`
`mongoose_push_notification_send_time_microsecond_sum{error_category=${CATEGORY},error_reason=${REASON},service=${SERVICE},status=${STATUS}}`
`mongoose_push_notification_send_time_microsecond_count{error_category=${CATEGORY},error_reason=${REASON},service=${SERVICE},status=${STATUS}}`

Where:
* `STATUS` is `"success"` for the successful notifications or `"error"` in all other cases
* `SERVICE` is either `"apns"` or `"fcm"`
* `CATEGORY` is an arbitrary error category term (in case of `status="error"`) or an empty string (when `status="success"`)
* `REASON` is an arbitrary error reason term (in case of `status="error"`) or an empty string (when `status="success"`)
* `LE` defines the `upper inclusive bound` (`less than or equal`) values for buckets, currently `1000`, `10_000`, `25_000`, `50_000`, `100_000`, `250_000`, `500_000`, `1000_000` or `+Inf`

This histogram metric shows the distribution of times needed to:
1. Select a worker (this may include waiting time when all workers are busy).
2. Send a request.
3. Get a response from push notifications provider.

###### HTTP/2 requests

`sparrow_pool_request_duration_microsecond_bucket{pool=${POOL},result=${RESULT},le=${LE}}`
`sparrow_pool_request_duration_microsecond_sum{pool=${POOL},result=${RESULT}}`
`sparrow_pool_request_duration_microsecond_count{pool=${POOL},result=${RESULT}}`

Where:
* `POOL` is the name of the connection pool
* `RESULT` is `"ok"` when a response was received (whatever its status is) or `"error"` when the request failed without a response
* `LE` defines the `upper inclusive bound` (`less than or equal`) values for buckets, currently `10_000`, `25_000`, `50_000`, `100_000`, `200_000`, `500_000`, `1000_000` or `+Inf`

This histogram metric shows the distribution of times needed to send a request and receive a response. This includes:
1. Open a new stream within an already established connection.
2. Send a request, again if it could not be sent.
3. Receive a response.

Requests with `result="error"` include the ones which could not be sent until their time was up, so they take as long as the timeout of the request.

###### Connecting to push notification services

`sparrow_pool_connect_duration_microsecond_bucket{pool=${POOL},result=${RESULT},le=${LE}}`
`sparrow_pool_connect_duration_microsecond_sum{pool=${POOL},result=${RESULT}}`
`sparrow_pool_connect_duration_microsecond_count{pool=${POOL},result=${RESULT}}`

Where:
* `POOL` is the name of the connection pool
* `RESULT` is `"ok"` when the connection was established or `"error"` when the attempt failed
* `LE` defines the `upper inclusive bound` (`less than or equal`) values for buckets, currently `10_000`, `25_000`, `50_000`, `100_000`, `250_000`, `500_000`, `1000_000`, `5000_000` or `+Inf`

This histogram metric shows the distribution of times taken by attempts to connect to a push notification service, including the TLS handshake.

> **NOTE**
>
> A bucket of value 250_000 will keep the count of measurements that are less than or equal to 250_000.
> A measurement of value 51_836 will be added to all the buckets where the upper bound is greater than 51_836.
> In this case these are buckets `100_000`, `250_000`, `500_000`, `1000_000` and `+Inf`

#### Counters

* `mongoose_push_supervisor_init_count{service=${SERVICE}}` - Counts the number of push notification service supervisor starts.
  The `SERVICE` variable can take `"apns"` or `"fcm"` as a value.
  This metric is updated when MongoosePush starts, and later on when the underlying supervision tree is terminated and the error is propagated to the main application supervisor.
* `mongoose_push_apns_state_init_count` - Counts the number of APNS state initialisations.
* `mongoose_push_apns_state_terminate_count` - Counts the number of APNS state terminations.
* `mongoose_push_apns_state_get_default_topic_count` - Counts the number of default topic reads from cache.
* `sparrow_pool_request_count{pool=${POOL},result=${RESULT},reason=${REASON},status=${STATUS}}` - Counts the number of requests sent to push notification services.
  `RESULT` is `"ok"` when a response was received, and then `STATUS` is its HTTP status, e.g. `"200"` or `"410"`.
  `RESULT` is `"error"` when the request failed without a response, and then `REASON` tells why, e.g. `"request_timeout"`, `"connection_lost"` or `"unable_to_connect"`.
* `sparrow_pool_retry_count{pool=${POOL},reason=${REASON}}` - Counts the number of requests which could not be sent at the first attempt and had to be sent again, e.g. because the connection was being reestablished (`"disconnected"`, `"pool_not_available"`) or the server had no free streams (`"too_many_concurrent_requests"`).
* `sparrow_pool_connect_count{pool=${POOL},result=${RESULT},reason=${REASON}}` - Counts the number of attempts to connect to push notification services.
  `RESULT` is `"ok"` for established connections and `"error"` for failed attempts, and then `REASON` tells why, e.g. `"econnrefused"` or `"tls_alert"`.

#### Gauge

* `sparrow_pool_connections_gauge{pool=${POOL}}` - Number of connections a given `POOL` is configured to keep.
* `sparrow_pool_connected_gauge{pool=${POOL}}` - Number of currently established connections of a given `POOL`. It is lower than `sparrow_pool_connections_gauge` when some connections are being (re)established.
* `vm_memory_total` - Total amount of currently allocated memory.
* `vm_memory_processes` - Amount of memory currently allocated for processes.
* `vm_memory_processes_used` - Amount of memory currently used for processes.
* `vm_memory_binary` - Amount of memory currently allocated for binaries.
* `vm_memory_ets` - Amount of memory currently allocated for ETS tables.
* `vm_total_run_queue_lengths_total` - A sum of all current run queue lengths.
* `vm_total_run_queue_lengths_cpu` - A sum of current CPU schedulers' run queue lengths.
* `vm_system_counts_process_count` - Number of process currently existing at the local node.

## How to quickly see all metrics

```bash
curl -k https://127.0.0.1:8443/metrics
```

The above command assumes that MongoosePush runs on `localhost` and listens on port `8443`.
Please, mind the `HTTPS` protocol, metrics are hosted on the same port than all the other API endpoints.

## Prometheus configuration

When configuring Prometheus, it's important to:
* set the `scheme` to `https`,
* set the `insecure_skip_verify` to `true` if the default self-signed certificates are used.

```yaml
scrape_configs:
  - job_name: 'mongoose-push'
    scheme: 'https' #MongoosePush exposes encrypted endpoint - HTTPS
    tls_config: #The default certs used by MongoosePush are self-signed
      insecure_skip_verify: true #For checking purposes we can ignore certs verification
    static_configs:
      - targets: ['mongoose-push:8443']
        labels:
          group: 'production'

```
