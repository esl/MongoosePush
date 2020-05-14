defmodule MongoosePush.API.PrometheusEndpointTest do
  use ExUnit.Case, async: false
  use AssertEventually, timeout: 5000, interval: 10

  alias MongoosePush.Support.API, as: Tools

  @url "/v1/notification/f534534543"

  setup do
    Tools.reset(:fcm)
    :ok
  end

  @tag :skip
  test "Metrics can be correctly received from Prometheus" do
    # Push some notification to trigger metrics
    notification = %{
      :service => :fcm,
      :body => "A message from someone",
      :title => "Notification title"
    }

    assert {200, _} = Tools.post(@url, notification)

    # Fetch the metrics
    {status, headers, metrics} = Tools.get("/metrics")

    # 1. Status is 200
    assert 200 == status

    # 2. content type is text/plain
    {"content-type", resp} = List.keyfind(headers, "content-type", 0)
    assert String.contains?(resp, "text/plain")

    # 3. regex on the payload to make sure this is prometheus output
    fcm_regex =
      ~r/mongoose_push_notification_send_time_count{error_category=\"\",error_reason=\"\",service=\"fcm\",status=\"success\"} (?<count>[\d]+)/

    fcm_match = Regex.named_captures(fcm_regex, metrics)
    assert 0 != fcm_match
  end
end
