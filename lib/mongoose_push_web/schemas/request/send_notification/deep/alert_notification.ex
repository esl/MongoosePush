defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertNotification do
  require OpenApiSpex
  alias MongoosePushWeb.Protocols.RequestDecoder
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.AlertNotification",
    description: "In this request alert field is mandatory.",
    type: :object,
    properties: Map.merge(Deep.base()[:properties], Deep.alert()[:properties]),
    required: Deep.base()[:required] ++ Deep.alert()[:required],
    example: Map.merge(Deep.base()[:example], Deep.alert()[:example]),
    additionalProperties: false
  })

  defimpl RequestDecoder,
    for: MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertNotification do
    alias MongoosePushWeb.Protocols.RequestDecoderHelper

    @spec decode(%Deep.AlertNotification{}) :: MongoosePush.request()
    def decode(schema) do
      %{
        service: String.to_atom(schema.service),
        alert: RequestDecoder.decode(schema.alert)
      }
      |> RequestDecoderHelper.add_optional_fields(schema)
    end
  end
end
