defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.Alert do
  require OpenApiSpex
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.Alert",
    description: "In this request one can pass alert field only.",
    type: :object,
    properties: Map.merge(Deep.base()[:properties], Deep.alert()[:properties]),
    required: Deep.base()[:required] ++ Deep.alert()[:required],
    example: Map.merge(Deep.base()[:example], Deep.alert()[:example]),
    additionalProperties: false
  })
end
