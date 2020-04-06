defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.Data do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.Data",
    description: "In this request one can pass data field only.",
    type: :object,
    allOf: [MongoosePushWeb.Schemas.Request.SendNotification.Deep],
    properties: %{
      data: %Schema{
        type: :object,
        description:
          "Custom key-values pairs of the message's payload. " <>
            "The FCM request with nested data can end up with error."
      }
    },
    required: [:data],
    example: %{
      "service" => "apns",
      "data" => %{
        "custom" => "data fields",
        "some_id" => 345_645_332,
        "nested" => %{"fields" => "allowed"}
      }
    }
  })
end
