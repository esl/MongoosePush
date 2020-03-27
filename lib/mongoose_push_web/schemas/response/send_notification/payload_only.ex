defmodule MongoosePushWeb.Schemas.Response.SendNotification.PayloadOnly do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "APIv1.Response.Push",
    description: "Response schema for push notification request",
    type: :object,
    properties: %{},
    example: %{}
  })
end
