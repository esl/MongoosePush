defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep",
    oneOf: [
      MongoosePushWeb.Schemas.Request.SendNotification.Deep.Alert,
      MongoosePushWeb.Schemas.Request.SendNotification.Deep.Data
    ]
  })

  def base() do
    %{
      properties: %{
        alert: %Schema{
          type: :object,
          properties: %{
            body: %Schema{type: :string, description: "Body of the notification", format: :text},
            title: %Schema{
              type: :string,
              description: "Title of the notification",
              format: :text
            },
            badge: %Schema{type: :integer, format: :int32},
            click_action: %Schema{type: :string},
            tag: %Schema{type: :string},
            sound: %Schema{type: :string}
          },
          required: [:body, :title]
        },
        data: %Schema{
          type: :object,
          description:
            "Custom key-values pairs of the message's payload. " <>
              "The FCM request with nested data can end up with error."
        },
        service: %Schema{
          type: :string,
          description: "Push notification service",
          format: :text,
          enum: ["fcm", "apns"]
        },
        mode: %Schema{type: :string, enum: ["prod", "dev"]},
        priority: %Schema{
          type: :string,
          description: "The default one is chosen based on the service being used",
          enum: ["normal", "high"]
        },
        time_to_live: %Schema{type: :integer, format: :int32},
        mutable_content: %Schema{type: :boolean, default: false},
        tags: %Schema{
          type: :array,
          description:
            "Used when choosing pool to match request tags when sending a notification",
          items: %Schema{type: :string, format: :text}
        },
        # Only for APNS, alert/data independent
        topic: %Schema{type: :string}
      },
      required: [:service],
      example: %{
        "service" => "apns",
        "mode" => "prod",
        "priority" => "normal",
        "time_to_live" => 3600,
        "mutable_content" => false,
        "tags" => ["some", "tags", "for", "pool", "selection"],
        "topic" => "com.someapp"
      }
    }
  end

  def alert() do
    %{
      required: [:alert],
      example: %{
        "alert" => %{
          "body" => "A message from someone",
          "title" => "Notification title",
          "badge" => 7,
          "click_action" => ".SomeApp.Handler.action",
          "tag" => "info",
          "sound" => "standard.mp3"
        }
      }
    }
  end

  def data() do
    %{
      required: [:data],
      example: %{
        "data" => %{
          "custom" => "data fields",
          "some_id" => 345_645_332,
          "nested" => %{"fields" => "allowed"}
        }
      }
    }
  end
end
