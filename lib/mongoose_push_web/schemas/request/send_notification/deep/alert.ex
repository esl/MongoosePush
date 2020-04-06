defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.Alert do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.Alert",
    description: "In this request one can pass alert field only.",
    type: :object,
    allOf: MongoosePushWeb.Schemas.Request.SendNotification.Deep,
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
    required: [:alert],
    example: %{
      "service" => "apns",
      "alert" => %{"body" => "A message from someone", "title" => "Notification title"}
    }
  })
end
