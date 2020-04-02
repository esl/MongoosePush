defmodule MongoosePushWeb.Schemas.Response.SendNotification.TooManyRequests do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Response.SendNotification.TooManyRequests",
    description: "The user has sent too many requests in a given amount of time",
    type: :object,
    properties: %{
      reason: %Schema{
        type: :string,
        format: :string,
        enum: ["too_many_requests"]
      }
    },
    required: [:reason],
    example: %{"reason" => "too_many_requests"}
  })
end
