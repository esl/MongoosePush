defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.Common.Data do
  require OpenApiSpex
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.Common.Data",
    description:
      "Custom key-values pairs of the message's payload. " <>
        "The FCM request with nested data can end up with error.",
    type: :object,
    example: Deep.data()[:example]["data"],
    additionalProperties: nil
  })
end
