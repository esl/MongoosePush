defmodule MongoosePushWeb.Schemas.Response.SendNotification.ServiceUnavailable do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Response.SendNotification.ServiceUnavailable",
    description: "The server is not ready to handle the request",
    type: :object,
    properties: %{
      reason: %Schema{
        type: :string,
        format: :text,
        enum: [
          "service_internal",
          "internal_config",
          "connection_lost",
          "unable_to_connect",
          "unspecified"
        ]
      }
    },
    required: [:reason],
    example: %{"reason" => "connection_lost"}
  })
end
