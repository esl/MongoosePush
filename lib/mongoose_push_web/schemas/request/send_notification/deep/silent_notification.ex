defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.SilentNotification do
  require OpenApiSpex
  alias MongoosePushWeb.Protocols.RequestDecoder
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.SilentNotification",
    description: "In this request data field is mandatory.",
    type: :object,
    properties: Map.merge(Deep.base()[:properties], Deep.data()[:properties]),
    required: Deep.base()[:required] ++ Deep.data()[:required],
    example: Map.merge(Deep.base()[:example], Deep.data()[:example]),
    additionalProperties: false
  })

  defimpl RequestDecoder,
    for: MongoosePushWeb.Schemas.Request.SendNotification.Deep.SilentNotification do
    alias MongoosePushWeb.Protocols.RequestDecoderHelper

    @spec decode(%Deep.SilentNotification{}) :: MongoosePush.request()
    def decode(schema) do
      %{
        service: String.to_atom(schema.service),
        data: schema.data
      }
      |> RequestDecoderHelper.add_optional_fields(schema)
    end
  end
end
