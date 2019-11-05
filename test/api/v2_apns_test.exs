defmodule MongoosePushAPIV2APNSTest do
  require Logger
  use ExUnit.Case, async: false
  use Quixir
  import MongoosePushSupportAPI

  alias HTTPoison.Response
  doctest MongoosePush.API.V2

  @url "/v2/notification/f534534543"

  setup do
    reset(:apns)
    TestHelper.reload_app()
  end

  test "push to apns with invalid token fails" do
    reason = "BadDeviceToken"
    args = %{
      :service => :apns,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}

    mock_apns([%{device_token: "f534534543", status: 400, reason: reason}])

    assert {500, reason} = post(@url, args)
  end

  test "push to apns with bad certificate fails" do
    reason = "BadCertificate"
    args = %{
      :service => :apns,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}

    mock_apns([%{device_token: "f534534543", status: 403, reason: reason}])

    assert {500, reason} = post(@url, args)
  end

  test "push to apns with bad path fails" do
    reason = "BadPath"
    args = %{
      :service => :apns,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}

    mock_apns([%{device_token: "f534534543", status: 404, reason: reason}])

    assert {500, reason} = post(@url, args)
  end

  test "push to apns with bad method fails" do
    reason = "MethodNotAllowed"
    args = %{
      :service => :apns,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}

    mock_apns([%{device_token: "f534534543", status: 405, reason: reason}])

    assert {500, reason} = post(@url, args)
  end

  test "push to apns with unregistered token fails" do
    reason = "Unregistered"
    args = %{
      :service => :apns,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}

    mock_apns([%{device_token: "f534534543", status: 410, reason: reason}])

    assert {500, reason} = post(@url, args)
  end


  test "push to apns with too large payload fails" do
    reason = "PayloadTooLarge"
    args = %{
      :service => :apns,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}

    mock_apns([%{device_token: "f534534543", status: 413, reason: reason}])

    assert {500, reason} = post(@url, args)
  end

  test "push to apns fails with unknown internal error" do
    reason = "InternalServerError"
    args = %{
      :service => :apns,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}

    mock_apns([%{device_token: "f534534543", status: 500, reason: reason}])

    assert {500, reason} = post(@url, args)
  end

  test "push to apns fails with too many requests" do
    reason = "TooManyRequests"
    args = %{
      :service => :apns,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}

    mock_apns([%{device_token: "f534534543", status: 429, reason: reason}])

    assert {500, reason} = post(@url, args)
  end

  test "push to apns fails when service is unavailable/overloaded" do
    reason = "ServiceUnavailable"
    args = %{
      :service => :apns,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}

    mock_apns([%{device_token: "f534534543", status: 503, reason: reason}])

    assert {500, reason} = post(@url, args)
  end
end
