defmodule MongoosePushWeb.Schemas.Request.SendNotification.Flat do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Flat",
    description: "Push notification request schema",
    type: :object,
    properties: %{
      service: %Schema{
        type: :string,
        description: "Push notification service",
        format: :text,
        enum: ["fcm", "apns"]
      },
      body: %Schema{type: :string, description: "Body of the notification", format: :text},
      title: %Schema{type: :string, description: "Title of the notification", format: :text},
      badge: %Schema{type: :integer, format: :int32},
      click_action: %Schema{type: :string},
      tag: %Schema{type: :string},
      topic: %Schema{type: :string},
      data: %Schema{
        type: :object,
        description:
          "Custom key-values pairs of the message's payload. " <>
            "The FCM request with nested data can end up with error."
      },
      mode: %Schema{type: :string, enum: ["prod", "dev"]}
    },
    required: [:service, :body, :title],
    example: %{
      "service" => "apns",
      "body" => "A message from someone",
      "title" => "Notification title",
      "badge" => 7,
      "click_action" => ".SomeApp.Handler.action",
      "tag" => "info",
      "topic" => "com.someapp",
      "data" => %{
        "custom" => "data fields",
        "some_id" => 345_645_332,
        "nested" => %{"fields" => "allowed"}
      },
      "mode" => "prod"
    },
    additionalProperties: false
  })
end
