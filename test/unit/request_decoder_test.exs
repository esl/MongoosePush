defmodule RequestDecoderTest do
  use ExUnit.Case, async: false
  alias MongoosePushWeb.Protocols.RequestDecoder
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertNotification
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep.SilentNotification
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep.Common.Alert
  alias MongoosePushWeb.Schemas.Request.SendNotification.FlatNotification

  test "FlatNotification: decoder does well with all-fields schema" do
    input = %FlatNotification{
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

  test "FlatNotification: decoder does not fail without optional alert fields" do
    input = %FlatNotification{
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

  test "FlatNotification: decoder does not fail without optional fields at all" do
    input = %FlatNotification{
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

  # Alert

  test "Alert: minimum fields schema" do
    input = %Alert{
      body: "A message from someone",
      title: "Notification title"
    }

    expected = %{
      body: "A message from someone",
      title: "Notification title"
    }

    assert expected == RequestDecoder.decode(input)
  end

  test "Alert: all-fields schema" do
    input = %Alert{
      body: "A message from someone",
      title: "Notification title",
      badge: 7,
      click_action: ".SomeApp.Handler.action",
      tag: "info",
      sound: "standard.mp3"
    }

    expected = %{
      body: "A message from someone",
      title: "Notification title",
      badge: 7,
      click_action: ".SomeApp.Handler.action",
      tag: "info",
      sound: "standard.mp3"
    }

    assert expected == RequestDecoder.decode(input)
  end

  test "Alert: badge + click_action" do
    input = %Alert{
      body: "A message from someone",
      title: "Notification title",
      badge: 7,
      click_action: ".SomeApp.Handler.action"
    }

    expected = %{
      body: "A message from someone",
      title: "Notification title",
      badge: 7,
      click_action: ".SomeApp.Handler.action"
    }

    assert expected == RequestDecoder.decode(input)
  end

  test "Alert: tag + sound" do
    input = %Alert{
      body: "A message from someone",
      title: "Notification title",
      tag: "info",
      sound: "standard.mp3"
    }

    expected = %{
      body: "A message from someone",
      title: "Notification title",
      tag: "info",
      sound: "standard.mp3"
    }

    assert expected == RequestDecoder.decode(input)
  end

  # AlertNotification

  test "AlertNotification: decoder does well with all-fields schema" do
    input = %AlertNotification{
      service: "apns",
      mode: "prod",
      priority: "normal",
      time_to_live: 3600,
      mutable_content: true,
      tags: ["some", "tags", "for", "pool", "selection"],
      topic: "com.someapp",
      alert: %Alert{
        body: "A message from someone",
        title: "Notification title",
        badge: 7,
        click_action: ".SomeApp.Handler.action",
        tag: "info",
        sound: "standard.mp3"
      },
      data: %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected = %{
      service: :apns,
      mode: :prod,
      priority: :normal,
      time_to_live: 3600,
      mutable_content: true,
      alert: %{
        body: "A message from someone",
        title: "Notification title",
        badge: 7,
        tag: "info",
        click_action: ".SomeApp.Handler.action",
        sound: "standard.mp3"
      },
      topic: "com.someapp",
      data: %{"acme1" => "value1", "acme2" => "value2"},
      tags: ["some", "tags", "for", "pool", "selection"]
    }

    assert expected == RequestDecoder.decode(input)
  end

  test "AlertNotification: minimum fields schema" do
    input = %AlertNotification{
      service: "fcm",
      alert: %Alert{
        body: "A message from someone",
        title: "Notification title"
      }
    }

    expected = %{
      service: :fcm,
      mutable_content: false,
      alert: %{
        body: "A message from someone",
        title: "Notification title"
      }
    }

    assert expected == RequestDecoder.decode(input)
  end

  # SilentNotification

  test "SilentNotification: decoder does well with all-fields schema" do
    input = %SilentNotification{
      service: "apns",
      mode: "prod",
      priority: "normal",
      time_to_live: 3600,
      mutable_content: true,
      tags: ["some", "tags", "for", "pool", "selection"],
      topic: "com.someapp",
      alert: %Alert{
        body: "A message from someone",
        title: "Notification title",
        badge: 7,
        click_action: ".SomeApp.Handler.action",
        tag: "info",
        sound: "standard.mp3"
      },
      data: %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected = %{
      service: :apns,
      mode: :prod,
      priority: :normal,
      time_to_live: 3600,
      mutable_content: true,
      tags: ["some", "tags", "for", "pool", "selection"],
      topic: "com.someapp",
      alert: %{
        body: "A message from someone",
        title: "Notification title",
        badge: 7,
        tag: "info",
        click_action: ".SomeApp.Handler.action",
        sound: "standard.mp3"
      },
      data: %{"acme1" => "value1", "acme2" => "value2"}
    }

    assert expected == RequestDecoder.decode(input)
  end

  test "SilentNotification: minimum fields schema" do
    input = %SilentNotification{
      service: "fcm",
      data: %{"acme1" => "value1", "acme2" => "value2"}
    }

    expected = %{
      service: :fcm,
      mutable_content: false,
      data: %{"acme1" => "value1", "acme2" => "value2"}
    }

    assert expected == RequestDecoder.decode(input)
  end
end
