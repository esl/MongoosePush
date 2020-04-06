defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertAndData do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.AlertAndData",
    description: "In this request one can pass both alert and data fields.",
    allOf: [
      MongoosePushWeb.Schemas.Request.SendNotification.Deep.Alert,
      MongoosePushWeb.Schemas.Request.SendNotification.Deep.Data
    ]
  })
end
