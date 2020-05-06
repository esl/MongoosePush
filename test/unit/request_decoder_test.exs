defmodule RequestDecoderTest do
  use ExUnit.Case, async: false
  alias MongoosePushWeb.Protocols.RequestDecoder
  alias MongoosePushWeb.Schemas.Request

  test "decoder does well with all-fields schema" do
    input = %Request.SendNotification.FlatNotification{
      badge: 7,
      body: "A message from someone",
      click_action: ".SomeApp.Handler.action",
      data: %{"acme1" => "value1", "acme2" => "value2"},
      mode: "prod",
      service: "apns",
      tag: "info",
      title: "Notification title",
      topic: "com.someapp"
    }

    expected = %{
      service: :apns,
      mode: :prod,
      alert: %{
        body: "A message from someone",
        title: "Notification title",
        badge: 7,
        tag: "info",
        click_action: ".SomeApp.Handler.action"
      },
      topic: "com.someapp",
      data: %{"acme1" => "value1", "acme2" => "value2"}
    }

    assert expected == RequestDecoder.decode(input)
  end

  test "decoder does not fail without optional alert fields" do
    input = %Request.SendNotification.FlatNotification{
      body: "A message from someone",
      service: "apns",
      title: "Notification title",
      data: %{"acme1" => "value1", "acme2" => "value2"},
      mode: "prod",
      topic: "com.someapp"
    }

    expected = %{
      service: :apns,
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      },
      mode: :prod,
      topic: "com.someapp",
      data: %{"acme1" => "value1", "acme2" => "value2"}
    }

    assert expected == RequestDecoder.decode(input)
  end

  test "decoder does not fail without optional fields at all" do
    input = %Request.SendNotification.FlatNotification{
      body: "A message from someone",
      service: "apns",
      title: "Notification title"
    }

    expected = %{
      service: :apns,
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      }
    }

    assert expected == RequestDecoder.decode(input)
  end
end
