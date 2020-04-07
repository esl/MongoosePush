defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep",
    oneOf: [
      MongoosePushWeb.Schemas.Request.SendNotification.Deep.Alert,
      MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertAndData,
      MongoosePushWeb.Schemas.Request.SendNotification.Deep.Data
    ]
  })

  def merge(map1, map2) do
    Map.merge(map1, map2, fn
      k, v1, v2 when k in [:properties, :example] -> Map.merge(v1, v2)
      :required, v1, v2 -> Enum.uniq(v1 ++ v2)
      _k, _v1, v2 -> v2
    end)
  end

  def base() do
    %{
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
          format: :string
        },
        # Only for APNS, alert/data independent
        topic: %Schema{type: :string}
      }
    }
  end

  def alert() do
    %{
      title: "Request.SendNotification.Deep.Alert",
      properties: %{
        alert: %Schema{
          type: :object,
          properties: %{
            body: %Schema{type: :string, description: "Body of the notification", format: :string},
            title: %Schema{
              type: :string,
              description: "Title of the notification",
              format: :string
            },
            badge: %Schema{type: :integer, format: :int32},
            click_action: %Schema{type: :string},
            tag: %Schema{type: :string},
            sound: %Schema{type: :string}
          },
          required: [:body, :title]
        }
      },
      required: [:service, :alert],
      example: %{
        "service" => "apns",
        "alert" => %{"body" => "A message from someone", "title" => "Notification title"}
      }
    }
  end

  def data() do
    %{
      title: "Request.SendNotification.Deep.Data",
      properties: %{
        data: %Schema{
          type: :object,
          description:
            "Custom key-values pairs of the message's payload. " <>
              "The FCM request with nested data can end up with error."
        }
      },
      required: [:service, :data],
      example: %{
        "service" => "apns",
        "data" => %{
          "custom" => "data fields",
          "some_id" => 345_645_332,
          "nested" => %{"fields" => "allowed"}
        }
      }
    }
  end

  def alert_and_data_info() do
    %{
      title: "Request.SendNotification.Deep.AlertAndData"
    }
  end
end
