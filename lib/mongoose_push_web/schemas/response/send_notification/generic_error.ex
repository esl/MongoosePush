defmodule MongoosePushWeb.Schemas.Response.SendNotification.GenericError do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Response.SendNotification.GenericError",
    description: "Response schema for push notification request",
    type: :object,
    properties: %{
      details: %Schema{
        type: :string,
        description:
          "Short description of the encountered error. For development/debugging purposes only, " <>
            "not for any client usage, as it may change in time without prior notice."
      }
    },
    example: %{
      "details" => "{\"details\":\"Parsing Param Error: body\"}"
    }
  })
end
