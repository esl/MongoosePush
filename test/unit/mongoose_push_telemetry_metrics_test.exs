defmodule MongoosePushTelemetryMetricsTest do
  use ExUnit.Case, async: false
  use AssertEventually
  require Integer
  import Mox

  alias MongoosePush.Service.APNS
  alias MongoosePush.Service.FCM

  use MongoosePushWeb.ConnCase, async: false

  setup do
    TestHelper.reload_app()

    # TelemetryMetricsPrometheus starts asynchronously - we need to wait until metrics are
    # registered, otherwise tests could run into a race condition.
    # Because of how TelemetryMetricsPrometheus startup is implemented right now, the following
    # call alone will only return after the initialization (first one will be successful),
    # but in case something would change in future we'll "wait" and retry until it returns
    # at least one metric.
    eventually(
      assert [_ | _] = TelemetryMetricsPrometheus.Core.Registry.metrics(:prometheus_metrics)
    )

    Application.put_env(:mongoose_push, MongoosePush.Service,
      fcm: MongoosePush.Service.Mock,
      apns: MongoosePush.Service.Mock
    )

    :ok
  end

  test "push success metrics" do
    for service <- [:fcm, :apns], do: do_push(:ok, service, 10)

    metrics = TelemetryMetricsPrometheus.Core.scrape()

    # Distribution metric contains count as well as the buckets
    fcm_regex =
      ~r/mongoose_push_notification_send_time_microsecond_count{error_category=\"\",error_reason=\"\",service=\"fcm\",status=\"success\"} (?<count>[\d]+)/

    fcm_match = Regex.named_captures(fcm_regex, metrics)
    fcm_count = get_count(fcm_match)

    apns_regex =
      ~r/mongoose_push_notification_send_time_microsecond_count{error_category=\"\",error_reason=\"\",service=\"apns\",status=\"success\"} (?<count>[\d]+)/

    apns_match = Regex.named_captures(apns_regex, metrics)
    apns_count = get_count(apns_match)

    assert 20 == fcm_count + apns_count
  end

  describe "push error" do
    setup do
      for n <- 1..3 do
        reason = String.to_atom("reason_" <> Integer.to_string(n))
        type = String.to_atom("type_" <> Integer.to_string(n))
        for service <- [:fcm, :apns], do: do_push({:error, {type, reason}}, service, 5)
      end

      :ok
    end

    test "metrics" do
      metrics = TelemetryMetricsPrometheus.Core.scrape()

      # Distribution metric contains count as well as the buckets
      fcm_regex =
        ~r/mongoose_push_notification_send_time_microsecond_count{error_category=\"(?<type>[^\s]*)\",error_reason=\"(?<reason>[^\s]*)\",service=\"fcm\",status=\"error\"} (?<count>[\d]+)/

      apns_regex =
        ~r/mongoose_push_notification_send_time_microsecond_count{error_category=\"(?<type>[^\s]*)\",error_reason=\"(?<reason>[^\s]*)\",service=\"apns\",status=\"error\"} (?<count>[\d]+)/

      fcm_matches =
        fcm_regex
        |> Regex.scan(metrics)
        |> Enum.map(&hd/1)
        |> Enum.map(fn s -> Regex.named_captures(fcm_regex, s) end)

      apns_matches =
        apns_regex
        |> Regex.scan(metrics)
        |> Enum.map(&hd/1)
        |> Enum.map(fn s -> Regex.named_captures(apns_regex, s) end)

      errors =
        List.foldl(fcm_matches ++ apns_matches, %{}, fn match, acc ->
          type = Map.get(match, "type")
          reason = Map.get(match, "reason")
          count = get_count(match)
          Map.update(acc, [type, reason], count, fn val -> val + count end)
        end)

      assert 3 == length(Map.keys(errors))
      assert true == Enum.all?(Map.values(errors), fn val -> val == 10 end)
    end
  end

  test "APNS default topic extraction metrics" do
    for n <- 1..10 do
      pool_name = String.to_atom("pool_" <> Integer.to_string(n))
      def_topic = "default_topic_" <> Integer.to_string(n)
      :ets.insert(:apns_state, {pool_name, def_topic})
      assert def_topic == APNS.State.get_default_topic(pool_name)
    end

    metrics = TelemetryMetricsPrometheus.Core.scrape()
    regex = ~r/mongoose_push_apns_state_get_default_topic_count (?<count>[\d]+)/
    match = Regex.named_captures(regex, metrics)
    count = get_count(match)

    assert 10 == count
  end

  test "Metrics can be correctly received from Prometheus" do
    for service <- [:fcm, :apns], do: do_push(:ok, service, 10)
    metrics = get(build_conn(), "/metrics")

    # 1. Status is 200
    assert 200 == metrics.status

    # 2. content type is text/plain
    [resp] = get_resp_header(metrics, "content-type")
    assert String.contains?(resp, "text/plain")

    # 3. regex on the payload to make sure this is prometheus output
    fcm_regex =
      ~r/mongoose_push_notification_send_time_microsecond_count{error_category=\"\",error_reason=\"\",service=\"fcm\",status=\"success\"} (?<count>[\d]+)/

    fcm_match = Regex.named_captures(fcm_regex, metrics.resp_body)
    assert nil != fcm_match
  end

  test "sparrow pool metrics" do
    stats = Sparrow.Pool.stats()
    assert [_ | _] = stats

    MongoosePush.Metrics.TelemetryMetrics.running_pools()

    metrics = TelemetryMetricsPrometheus.Core.scrape()

    for %{pool: pool, connections: connections} <- stats do
      assert metrics =~ ~s(sparrow_pool_connections_gauge{pool="#{pool}"} #{connections}\n)
      assert metrics =~ ~r/sparrow_pool_connected_gauge{pool="#{pool}"} \d+\n/
    end
  end

  test "sparrow request, retry and connection metrics" do
    pool_info = %{
      domain: "localhost",
      port: 443,
      pool_type: :fcm,
      pool_name: :metrics_pool,
      pool_tags: []
    }

    request = fn metadata ->
      :telemetry.execute(
        [:sparrow, :pool, :request],
        %{time: 20_000},
        Map.merge(pool_info, metadata)
      )
    end

    connect = fn metadata ->
      :telemetry.execute(
        [:sparrow, :pool, :connect],
        %{time: 20_000},
        Map.merge(pool_info, metadata)
      )
    end

    request.(%{result: :ok, reason: nil, status: 200})
    request.(%{result: :ok, reason: nil, status: 410})

    request.(%{
      result: :error,
      reason: {:unable_to_connect, :pool_not_available},
      status: nil
    })

    request.(%{result: :error, reason: "not an atom", status: nil})

    :telemetry.execute(
      [:sparrow, :pool, :retry],
      %{},
      Map.put(pool_info, :reason, :disconnected)
    )

    connect.(%{result: :ok, reason: nil})
    connect.(%{result: :error, reason: {:tls_alert, {:bad_certificate, ~c"alert"}}})

    metrics = TelemetryMetricsPrometheus.Core.scrape()

    for line <- [
          ~s(sparrow_pool_request_count{pool="metrics_pool",reason="",result="ok",status="200"} 1),
          ~s(sparrow_pool_request_count{pool="metrics_pool",reason="",result="ok",status="410"} 1),
          ~s(sparrow_pool_request_count{pool="metrics_pool",reason="unable_to_connect",result="error",status=""} 1),
          ~s(sparrow_pool_request_count{pool="metrics_pool",reason="other",result="error",status=""} 1),
          ~s(sparrow_pool_request_duration_microsecond_count{pool="metrics_pool",result="ok"} 2),
          ~s(sparrow_pool_request_duration_microsecond_count{pool="metrics_pool",result="error"} 2),
          ~s(sparrow_pool_retry_count{pool="metrics_pool",reason="disconnected"} 1),
          ~s(sparrow_pool_connect_count{pool="metrics_pool",reason="",result="ok"} 1),
          ~s(sparrow_pool_connect_count{pool="metrics_pool",reason="tls_alert",result="error"} 1),
          ~s(sparrow_pool_connect_duration_microsecond_count{pool="metrics_pool",result="ok"} 1)
        ] do
      assert metrics =~ line <> "\n"
    end
  end

  defp do_push(push_result, service, repeat_no) do
    MongoosePush.Service.Mock
    |> expect(:push, repeat_no, fn _, _, _, _ -> push_result end)
    |> stub_with(FCM)

    for _ <- 1..repeat_no do
      assert push_result ==
               MongoosePush.push("device_id", %{service: service, title: "", body: "", mode: :dev})
    end

    :ok
  end

  defp get_count(match) do
    {count, _} =
      match
      |> Map.get("count")
      |> Integer.parse()

    count
  end
end
