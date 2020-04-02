defmodule MongoosePushWeb.Schemas.Response.SendNotification.Gone do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Response.SendNotification.Gone",
    description:
      "The response sent when the requested content has been " <>
        "permanently deleted from server, with no forwarding address",
    type: :object,
    properties: %{
      reason: %Schema{
        type: :string,
        format: :string,
        enum: ["unregistered"]
      }
    },
    required: [:reason],
    example: %{"reason" => "unregistered"}
  })
end
