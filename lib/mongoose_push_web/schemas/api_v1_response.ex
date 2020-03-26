defmodule MongoosePushWeb.Schemas.APIv1Response do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "APIv1Response",
    description: "Response schema for push notification request",
    type: :object,
    properties: %{},
    example: %{}
  })
end
