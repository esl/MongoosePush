defmodule MongoosePushTelemetryMetricsTest do
  use ExUnit.Case, async: false
  use AssertEventually
  require Integer
  import Mox
  import MongoosePush

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

  test "sparrow periodic metrics" do
    :telemetry.execute(
      [:sparrow, :pools_warden, :workers],
      %{count: 5},
      %{pool: :periodic_pool}
    )

    :telemetry.execute(
      [:sparrow, :pools_warden, :pools],
      %{count: 3},
      %{}
    )

    metrics = TelemetryMetricsPrometheus.Core.scrape()
    workers_regex = ~r/sparrow_pools_warden_workers_count{pool=\"periodic_pool\"} 5/
    workers_match = Regex.match?(workers_regex, metrics)
    pools_regex = ~r/sparrow_pools_warden_pools_count [\d]+/
    pools_match = Regex.match?(pools_regex, metrics)

    assert true == workers_match
    assert true == pools_match
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
