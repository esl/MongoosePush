defmodule MongoosePushMetricsTest do
  use ExUnit.Case, async: false
  use Quixir
  import MongoosePush
  import Mock
  import TimeHelper
  doctest MongoosePush.Metrics

  alias MongoosePush.Service.APNS
  alias MongoosePush.Service.FCM

  describe "sprial metric" do
    test "'ok' increased by successful push" do
      test_metric(:spiral, "success", :ok)
    end

    test "'error.all' increased by failed push with 'atom' reason" do
      ptest [reason: atom(min: 3, max: 15)], repeat_for: 3 do
        test_metric(:spiral, "error.all", {:error, reason})
      end
    end

    test "'error.all' increased by failed push with 'any' reason" do
      ptest [reason: choose(from: [int(), bool(), string(min: 3, max: 20)])], repeat_for: 3 do
        test_metric(:spiral, "error.all", {:error, reason})
      end
    end

    test "'error.reason' increased by failed push with 'atom' reason" do
      ptest [reason: string(min: 3, max: 15, chars: ?a..?z)], repeat_for: 3 do
        test_metric(:spiral, ~s"error.#{reason}", {:error, :"#{reason}"})
      end
    end

    test "'error.unknown' increased by failed push with 'any' reason" do
      ptest [reason: choose(from: [int(), string(min: 3, max: 20)])], repeat_for: 3 do
        test_metric(:spiral, ~s"error.unknown", {:error, reason})
      end
    end
  end

  defp test_metric(type, metric_suffix, push_return) do
    with_mock APNS, [:passthrough], [push: fn(_, _, _, _) -> push_return end] do
    with_mock FCM,  [:passthrough], [push: fn(_, _, _, _) -> push_return end] do
    ptest [mode:    choose(from: [value(:dev), value(:prod)]),
           service: choose(from: [value(:fcm), value(:apns)])], repeat_for: 20 do
      metric_name = ~s"mongoose_push.#{type}s.push.#{service}.#{mode}."
                    <> metric_suffix

      metric_value0 = metric_value(type, metric_name)

      assert push_return = push("device_id",
                                %{service: service, title: "", body: "", mode: mode})
      wait_until fn ->
        metric_value1 = metric_value(type, metric_name)
        assert metric_value0 + 1 == metric_value1
      end
    end
    end
    end
  end

  defp metric_value(:spiral, metric_name) do
    case Elixometer.get_metric_value(metric_name) do
      {:ok, metric} ->
        metric[:count]
      {:error, :not_found} ->
        0
    end
  end
end
