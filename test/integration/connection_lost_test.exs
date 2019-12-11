defmodule MongoosePush.API.V3FCMTest do
  use ExUnit.Case, async: false
  use HelperMacros
  alias MongoosePush.Support.API, as: Tools

  @url "/v3/notification/f534534543"

  setup do
    if Mix.env() == :test do
      TestHelper.reload_app()
    end

    Tools.reset(:fcm)
    :ok
  end

  @tag integration: true
  test "When connection to FCM is lost and regained a PN succeeds" do
    Tools.mock_fcm("/connection", %{"https" => false})

    assert eventually({500, ""} == Tools.post_conn_error(@url, Tools.sample_notification(:fcm)))

    Tools.mock_fcm("/connection", %{"https" => true})

    assert eventually({200, nil} == Tools.post(@url, Tools.sample_notification(:fcm)))
  end
end
