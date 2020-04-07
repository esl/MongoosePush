defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertAndData do
  require OpenApiSpex
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  Deep.merge(Deep.base(), Deep.alert())
  |> Deep.merge(Deep.data())
  |> Deep.merge(Deep.alert_and_data_info())
  |> OpenApiSpex.schema()
end
