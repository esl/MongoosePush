defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.SilentNotification do
  require OpenApiSpex
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.SilentNotification",
    description: "In this request data field is mandatory.",
    type: :object,
    properties: Deep.base()[:properties],
    required: Deep.base()[:required] ++ Deep.data()[:required],
    example: Map.merge(Deep.base()[:example], Deep.data()[:example]),
    additionalProperties: false
  })
end
