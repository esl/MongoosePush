defmodule MongoosePush.API.ConnectionTest do
  use ExUnit.Case, async: false
  use AssertEventually, timeout: 5000, interval: 10

  alias MongoosePush.Support.API, as: Tools

  @url "/v3/notification/f534534543"

  setup do
    Tools.reset(:fcm)
    :ok
  end

  @tag integration: true
  test "When connection to FCM is lost and regained a PN succeeds" do
    Tools.mock_fcm("/connection", %{"https" => false})

    eventually(assert {500, ""} == Tools.post_conn_error(@url, Tools.sample_notification(:fcm)))

    Tools.mock_fcm("/connection", %{"https" => true})

    eventually(assert {200, nil} == Tools.post(@url, Tools.sample_notification(:fcm)))
  end
end
