defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.Data do
  require OpenApiSpex
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  Deep.merge(Deep.base(), Deep.data())
  |> OpenApiSpex.schema()
end
