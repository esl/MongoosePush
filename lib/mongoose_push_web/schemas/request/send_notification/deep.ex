defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep",
    description: "Push notification request schema",
    type: :object,
    properties: %{
      service: %Schema{
        type: :string,
        description: "Push notification service",
        format: :string,
        enum: ["fcm", "apns"]
      },
      mode: %Schema{type: :string, enum: ["prod", "dev"]},
      priority: %Schema{type: :string, enum: ["normal", "high"]},
      time_to_live: %Schema{type: :integer, format: :int32},
      mutable_content: %Schema{type: :boolean, default: false},
      tags: %Schema{type: :string},
      # Only for APNS, alert/data independent
      topic: %Schema{type: :string},
      alert: %Schema{
        type: :object,
        properties: %{
          body: %Schema{type: :string, description: "Body of the notification", format: :string},
          title: %Schema{type: :string, description: "Title of the notification", format: :string},
          badge: %Schema{type: :integer, format: :int32},
          click_action: %Schema{type: :string},
          tag: %Schema{type: :string},
          sound: %Schema{type: :string}
        },
        required: [:body, :title]
      },
      data: %Schema{type: :string}
    },
    required: [:service, :alert],
    example: %{
      "service" => "apns",
      "alert" => %{"body" => "A message from someone", "title" => "Notification title"}
    }
  })
end
