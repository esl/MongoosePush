defmodule MongoosePush.API.ConnectionTest do
  use ExUnit.Case, async: false
  use AssertEventually, timeout: 5000, interval: 10

  alias MongoosePush.Support.API, as: Tools

  @url "/v3/notification/f534534543"

  setup do
    Tools.reset(:fcm)
    :ok
  end

  test "When connection to FCM is lost and regained a PN succeeds" do
    Tools.mock_fcm("/connection", %{"https" => false})

    Enum.each(1..5, fn _ ->
      eventually(assert {503, ""} == Tools.post_conn_error(@url, Tools.sample_notification(:fcm)))
      Process.sleep(1000)
    end)

    Tools.mock_fcm("/connection", %{"https" => true})

    Enum.each(1..5, fn _ ->
      eventually(
        assert {200, "null"} == Tools.post_conn_error(@url, Tools.sample_notification(:fcm))
      )

      Process.sleep(1000)
    end)
  end
end
