defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.Alert do
  require OpenApiSpex
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  Deep.merge(Deep.base(), Deep.alert())
  |> OpenApiSpex.schema()
end
