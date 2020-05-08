defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.Common.Alert do
  require OpenApiSpex
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.Common.Alert",
    description: "Schema representation of alert.",
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
    required: [:body, :title],
    example: Deep.alert()[:example]["alert"],
    additionalProperties: false
  })

  defimpl MongoosePushWeb.Protocols.RequestDecoder,
    for: MongoosePushWeb.Schemas.Request.SendNotification.Deep.Common.Alert do
    def decode(schema) do
      %{
        body: schema.body,
        title: schema.title,
        badge: schema.badge,
        click_action: schema.click_action,
        tag: schema.tag,
        sound: schema.sound
      }
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
    end
  end
end
