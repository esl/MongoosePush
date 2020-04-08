defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.Data do
  require OpenApiSpex
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.Data",
    description: "In this request one can pass data field only.",
    type: :object,
    properties: Map.merge(Deep.base()[:properties], Deep.data()[:properties]),
    required: Deep.base()[:required] ++ Deep.data()[:required],
    example: Map.merge(Deep.base()[:example], Deep.data()[:example])
  })
end
