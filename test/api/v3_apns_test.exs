defmodule MongoosePush.API.V3APNSTest do
  use ExUnit.Case, async: false
  alias MongoosePush.Support.API, as: Tools

  @url "/v3/notification/f534534543"

  setup do
    Tools.reset(:apns)
    TestHelper.reload_app()
  end

  test "push to apns with invalid token fails" do
    reason = "BadDeviceToken"

    Tools.mock_apns([%{device_token: "f534534543", status: 400, reason: reason}])

    assert {400, %{"reason" => "invalid_request"}} =
             Tools.post(@url, Tools.sample_notification(:apns))
  end

  test "push to apns with bad certificate fails" do
    reason = "BadCertificate"

    Tools.mock_apns([%{device_token: "f534534543", status: 403, reason: reason}])

    assert {503, %{"reason" => "service_internal"}} =
             Tools.post(@url, Tools.sample_notification(:apns))
  end

  test "push to apns with bad path fails" do
    reason = "BadPath"

    Tools.mock_apns([%{device_token: "f534534543", status: 404, reason: reason}])

    assert {503, %{"reason" => "internal_config"}} =
             Tools.post(@url, Tools.sample_notification(:apns))
  end

  test "push to apns with bad method fails" do
    reason = "MethodNotAllowed"

    Tools.mock_apns([%{device_token: "f534534543", status: 405, reason: reason}])

    assert {503, %{"reason" => "internal_config"}} =
             Tools.post(@url, Tools.sample_notification(:apns))
  end

  test "push to apns with unregistered token fails" do
    reason = "Unregistered"

    Tools.mock_apns([%{device_token: "f534534543", status: 410, reason: reason}])

    assert {410, %{"reason" => "unregistered"}} =
             Tools.post(@url, Tools.sample_notification(:apns))
  end

  test "push to apns with too large payload fails" do
    reason = "PayloadTooLarge"

    Tools.mock_apns([%{device_token: "f534534543", status: 413, reason: reason}])

    assert {413, %{"reason" => "payload_too_large"}} =
             Tools.post(@url, Tools.sample_notification(:apns))
  end

  test "push to apns fails with unknown internal error" do
    reason = "InternalServerError"

    Tools.mock_apns([%{device_token: "f534534543", status: 500, reason: reason}])

    assert {503, %{"reason" => "service_internal"}} =
             Tools.post(@url, Tools.sample_notification(:apns))
  end

  test "push to apns fails with too many requests" do
    reason = "TooManyRequests"

    Tools.mock_apns([%{device_token: "f534534543", status: 429, reason: reason}])

    assert {429, %{"reason" => "too_many_requests"}} =
             Tools.post(@url, Tools.sample_notification(:apns))
  end

  test "push to apns fails when service is unavailable/overloaded" do
    reason = "ServiceUnavailable"

    Tools.mock_apns([%{device_token: "f534534543", status: 503, reason: reason}])

    assert {503, %{"reason" => "service_internal"}} =
             Tools.post(@url, Tools.sample_notification(:apns))
  end

  test "push to apns succeeds" do
    desc = "OK"

    Tools.reset(:apns)

    assert {200, _} = Tools.post(@url, Tools.sample_notification(:apns))
  end
end
