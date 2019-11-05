defmodule MongoosePushAPIV2FCMTest do
  require Logger
  use ExUnit.Case, async: false
  use Quixir
  import MongoosePushSupportAPI
  doctest MongoosePush.API.V2

  @url "/v2/notification/f534534543"

  setup do
    reset(:fcm)
    TestHelper.reload_app()
  end

  test "push to fcm with unregistered token fails" do
    reason = "UNREGISTERED"

    mock_fcm([%{device_token: "f534534543", status: 404, reason: reason}])

    assert {500, reason} = post(@url, sample_notification())
  end

  test "push to fcm with id mismatch fails" do
    reason = "SENDER_ID_MISMATCH"

    mock_fcm([%{device_token: "f534534543", status: 403, reason: reason}])

    assert {500, reason} = post(@url, sample_notification())
  end

  test "push to fcm with the limit exceeded fails" do
    reason = "QUOTA_EXCEEDED"

    mock_fcm([%{device_token: "f534534543", status: 429, reason: reason}])

    assert {500, reason} = post(@url, sample_notification())
  end

  test "push to fcm fails with unknown internal error" do
    reason = "INTERNAL"

    mock_fcm([%{device_token: "f534534543", status: 500, reason: reason}])

    assert {500, reason} = post(@url, sample_notification())
  end

  test "push to fcm with invalid or missing certificate/web push fails" do
    reason = "THIRD_PARTY_AUTH_ERROR"

    mock_fcm([%{device_token: "f534534543", status: 401, reason: reason}])

    assert {500, reason} = post(@url, sample_notification())
  end

  test "push to fcm fails when service is unavailable/overloaded" do
    reason = "UNAVAILABLE"

    mock_fcm([%{device_token: "f534534543", status: 503, reason: reason}])

    assert {500, reason} = post(@url, sample_notification())
  end
end
