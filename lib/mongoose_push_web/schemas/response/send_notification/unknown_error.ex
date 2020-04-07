defmodule MongoosePushWeb.Schemas.Response.SendNotification.UnknownError do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Response.SendNotification.UnknownError",
    description: "The server returned an empty, unknown, or unexplained response",
    type: :object,
    properties: %{
      reason: %Schema{
        type: :string,
        format: :text
      }
    },
    required: [:reason],
    example: %{"reason" => "Web server is returning an unknown error"}
  })
end
