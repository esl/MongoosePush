defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertAndData do
  require OpenApiSpex
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.AlertAndData",
    description: "In this request one can pass both alert and data fields.",
    type: :object,
    properties:
      Deep.base()[:properties]
      |> Map.merge(Deep.alert()[:properties])
      |> Map.merge(Deep.data()[:properties]),
    required:
      Deep.base()[:required] ++
        Deep.alert()[:required] ++
        Deep.data()[:required],
    example:
      Deep.base()[:example]
      |> Map.merge(Deep.alert()[:example])
      |> Map.merge(Deep.data()[:example]),
    additionalProperties: false
  })
end
