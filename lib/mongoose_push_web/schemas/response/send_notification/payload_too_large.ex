defmodule MongoosePushWeb.Schemas.Response.SendNotification.PayloadTooLarge do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Response.SendNotification.PayloadTooLarge",
    description: "Response schema for push notification request",
    type: :object,
    properties: %{
      reason: %Schema{
        type: :string,
        format: :string,
        enum: ["payload_too_large"]
      }
    },
    required: [:reason],
    example: %{"reason" => "payload_too_large"}
  })
end
