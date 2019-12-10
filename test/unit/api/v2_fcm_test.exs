defmodule MongoosePush.API.V2FCMTest do
  use ExUnit.Case, async: false
  alias MongoosePush.Support.API, as: Tools

  @url "/v2/notification/f534534543"

  setup do
    Tools.reset(:fcm)
    TestHelper.reload_app()
  end

  test "push to fcm with unregistered token fails" do
    reason = "UNREGISTERED"

    Tools.mock_fcm([%{device_token: "f534534543", status: 404, reason: reason}])

    assert {500, %{"details" => reason}} = Tools.post(@url, Tools.sample_notification(:fcm))
  end

  test "push to fcm with id mismatch fails" do
    reason = "SENDER_ID_MISMATCH"

    Tools.mock_fcm([%{device_token: "f534534543", status: 403, reason: reason}])

    assert {500, %{"details" => reason}} = Tools.post(@url, Tools.sample_notification(:fcm))
  end

  test "push to fcm with the limit exceeded fails" do
    reason = "QUOTA_EXCEEDED"

    Tools.mock_fcm([%{device_token: "f534534543", status: 429, reason: reason}])

    assert {500, %{"details" => reason}} = Tools.post(@url, Tools.sample_notification(:fcm))
  end

  test "push to fcm fails with unknown internal error" do
    reason = "INTERNAL"

    Tools.mock_fcm([%{device_token: "f534534543", status: 500, reason: reason}])

    assert {500, %{"details" => reason}} = Tools.post(@url, Tools.sample_notification(:fcm))
  end

  test "push to fcm with invalid or missing certificate/web push fails" do
    reason = "THIRD_PARTY_AUTH_ERROR"

    Tools.mock_fcm([%{device_token: "f534534543", status: 401, reason: reason}])

    assert {500, %{"details" => reason}} = Tools.post(@url, Tools.sample_notification(:fcm))
  end

  test "push to fcm fails when service is unavailable/overloaded" do
    reason = "UNAVAILABLE"

    Tools.mock_fcm([%{device_token: "f534534543", status: 503, reason: reason}])

    assert {500, %{"details" => reason}} = Tools.post(@url, Tools.sample_notification(:fcm))
  end
end
