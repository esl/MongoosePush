defmodule MongoosePushTelemetryMetricsTest do
  use ExUnit.Case, async: false
  use Quixir
  import Mock
  import MongoosePush
  import Regex

  alias MongoosePush.Service.APNS
  alias MongoosePush.Service.FCM

  setup do
    TestHelper.reload_app()
  end

  test "push success metrics" do
    do_push(:ok, 20)

    metrics = TelemetryMetricsPrometheus.Core.scrape()

    fcm_regex =
      ~r/mongoose_push_push_time_count{reason=\"success\",service=\"fcm\",status=\"success\",type=\"success\"} (?<count>[\d]+)/

    fcm_match = Regex.named_captures(fcm_regex, metrics)
    fcm_count = get_count(fcm_match)

    apns_regex =
      ~r/mongoose_push_push_time_count{reason=\"success\",service=\"apns\",status=\"success\",type=\"success\"} (?<count>[\d]+)/

    apns_match = Regex.named_captures(apns_regex, metrics)
    apns_count = get_count(apns_match)

    assert 20 == fcm_count + apns_count
  end

  describe "push error" do
    setup do
      ptest [
              reason: atom(min: 3, max: 15),
              type: atom(min: 3, max: 15)
            ],
            repeat_for: 3 do
        do_push({:error, {type, reason}}, 10)
      end
    end

    test "metrics" do
      metrics = TelemetryMetricsPrometheus.Core.scrape()

      fcm_regex =
        ~r/mongoose_push_push_time_count{reason=\"(?<reason>[^\s]+)\",service=\"fcm\",status=\"error\",type=\"(?<type>[^\s]+)\"} (?<count>[\d]+)/

      apns_regex =
        ~r/mongoose_push_push_time_count{reason=\"(?<reason>[^\s]+)\",service=\"apns\",status=\"error\",type=\"(?<type>[^\s]+)\"} (?<count>[\d]+)/

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
    ptest [
            pool_name: atom(min: 3, max: 15),
            default_topic: string(min: 3, max: 15)
          ],
          repeat_for: 10 do
      :ets.insert(:apns_state, {pool_name, default_topic})
      APNS.State.get_default_topic(pool_name)
    end

    metrics = TelemetryMetricsPrometheus.Core.scrape()
    regex = ~r/mongoose_push_apns_state_get_default_topic_count (?<count>[\d]+)/
    match = Regex.named_captures(regex, metrics)
    count = get_count(match)

    assert 10 == count
  end

  defp do_push(push_result, repeat_no) do
    with_mock APNS, [:passthrough], push: fn _, _, _, _ -> push_result end do
      with_mock FCM, [:passthrough], push: fn _, _, _, _ -> push_result end do
        ptest [
                mode: choose(from: [value(:dev), value(:prod)]),
                service: choose(from: [value(:fcm), value(:apns)])
              ],
              repeat_for: repeat_no do
          assert push_result =
                   push(
                     "device_id",
                     %{service: service, title: "", body: "", mode: mode}
                   )
        end
      end
    end
  end

  defp get_count(match) do
    {count, _} =
      match
      |> Map.get("count")
      |> Integer.parse()

    count
  end
end
