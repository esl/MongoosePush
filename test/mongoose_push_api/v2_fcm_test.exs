defmodule MongoosePushAPIV2FCMTest do
  require Logger
  use ExUnit.Case, async: false
  use Quixir
  import MongoosePushAPITestHelper

  alias HTTPoison.Response
  doctest MongoosePush.API.V2

  @url "/v2/notification/f534534543"

  setup do
    reset(:fcm)
    TestHelper.reload_app()
  end

  test "push to fcm with unregistered token fails" do
    reason = "UNREGISTERED"
    args = %{
      :service => :fcm,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}


    mock_fcm([%{device_token: "f534534543", status: 404, reason: reason}])

    assert {500, reason} = post(@url, %{service: :fcm, alert: %{body: "body", title: "title"}})
  end

  test "push to fcm with id mismatch fails" do
    reason = "SENDER_ID_MISMATCH"
    args = %{
      :service => :fcm,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}


    mock_fcm([%{device_token: "f534534543", status: 403, reason: reason}])

    assert {500, reason} = post(@url, %{service: :fcm, alert: %{body: "body", title: "title"}})
  end

  test "push to fcm with the limit exceeded fails" do
    reason = "QUOTA_EXCEEDED"
    args = %{
      :service => :fcm,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}


    mock_fcm([%{device_token: "f534534543", status: 429, reason: reason}])

    assert {500, reason} = post(@url, %{service: :fcm, alert: %{body: "body", title: "title"}})
  end

  test "push to fcm fails with unknown internal error" do
    reason = "INTERNAL"
    args = %{
      :service => :fcm,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}


    mock_fcm([%{device_token: "f534534543", status: 500, reason: reason}])

    assert {500, reason} = post(@url, %{service: :fcm, alert: %{body: "body", title: "title"}})
  end

  test "push to fcm with invalid or missing certificate/web push fails" do
    reason = "THIRD_PARTY_AUTH_ERROR"
    args = %{
      :service => :fcm,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}


    mock_fcm([%{device_token: "f534534543", status: 401, reason: reason}])

    assert {500, reason} = post(@url, %{service: :fcm, alert: %{body: "body", title: "title"}})
  end

  test "push to fcm fails when service is unavailable/overloaded" do
    reason = "UNAVAILABLE"
    args = %{
      :service => :fcm,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}


    mock_fcm([%{device_token: "f534534543", status: 503, reason: reason}])

    assert {500, reason} = post(@url, %{service: :fcm, alert: %{body: "body", title: "title"}})
  end
end
