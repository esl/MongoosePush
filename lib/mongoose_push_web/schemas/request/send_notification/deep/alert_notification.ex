defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertNotification do
  require OpenApiSpex
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.AlertNotification",
    description: "In this request alert field is mandatory.",
    type: :object,
    properties: Deep.base()[:properties],
    required: Deep.base()[:required] ++ Deep.alert()[:required],
    example: Map.merge(Deep.base()[:example], Deep.alert()[:example]),
    additionalProperties: false
  })
end
