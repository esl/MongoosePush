defmodule MongoosePush.API.V3FCMTest do
  use ExUnit.Case, async: false
  alias MongoosePush.Support.API, as: Tools

  @url "/v3/notification/f534534543"

  setup_all do
    if Mix.env() == :integration do
      HTTPoison.start()
    end

    :ok
  end

  setup do
    case Mix.env() do
      :test ->
        Tools.reset(:fcm)
        TestHelper.reload_app()

      :integration ->
        Tools.reset(:fcm)
    end
  end

  @tag integration: true
  test "push to fcm with id mismatch fails" do
    reason = "SENDER_ID_MISMATCH"

    Tools.mock_fcm([%{device_token: "f534534543", status: 403, reason: reason}])

    assert {503, %{"reason" => "service_internal"}} =
             Tools.post(@url, Tools.sample_notification(:fcm))
  end

  @tag integration: true
  test "push to fcm with unregistered token fails" do
    reason = "UNREGISTERED"

    Tools.mock_fcm([%{device_token: "f534534543", status: 404, reason: reason}])

    assert {410, %{"reason" => "unregistered"}} =
             Tools.post(@url, Tools.sample_notification(:fcm))
  end

  @tag integration: true
  test "push to fcm with the limit exceeded fails" do
    reason = "QUOTA_EXCEEDED"

    Tools.mock_fcm([%{device_token: "f534534543", status: 429, reason: reason}])

    assert {429, %{"reason" => "too_many_requests"}} =
             Tools.post(@url, Tools.sample_notification(:fcm))
  end

  @tag integration: true
  test "push to fcm fails with unknown internal error" do
    reason = "INTERNAL"

    Tools.mock_fcm([%{device_token: "f534534543", status: 500, reason: reason}])

    assert {503, %{"reason" => "service_internal"}} =
             Tools.post(@url, Tools.sample_notification(:fcm))
  end

  @tag integration: true
  test "push to fcm with invalid or missing certificate/web push fails" do
    reason = "THIRD_PARTY_AUTH_ERROR"

    Tools.mock_fcm([%{device_token: "f534534543", status: 401, reason: reason}])

    assert {503, %{"reason" => "service_internal"}} =
             Tools.post(@url, Tools.sample_notification(:fcm))
  end

  @tag integration: true
  test "push to fcm fails when service is unavailable/overloaded" do
    reason = "UNAVAILABLE"

    Tools.mock_fcm([%{device_token: "f534534543", status: 503, reason: reason}])

    assert {503, %{"reason" => "service_internal"}} =
             Tools.post(@url, Tools.sample_notification(:fcm))
  end

  @tag integration: true
  test "push to fcm succeeds" do
    desc = "OK"

    Tools.reset(:fcm)

    assert {200, _} = Tools.post(@url, Tools.sample_notification(:fcm))
  end
end
