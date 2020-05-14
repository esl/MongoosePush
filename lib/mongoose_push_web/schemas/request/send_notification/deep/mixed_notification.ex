defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.MixedNotification do
  require OpenApiSpex
  alias MongoosePushWeb.Protocols.RequestDecoder
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.MixedNotification",
    description: "In this request both alert and data fields are mandatory.",
    type: :object,
    properties:
      Deep.base()[:properties]
      |> Map.merge(Deep.alert()[:properties])
      |> Map.merge(Deep.data()[:properties]),
    required: Deep.base()[:required] ++ Deep.alert()[:required] ++ Deep.data()[:required],
    example:
      Deep.base()[:example]
      |> Map.merge(Deep.alert()[:example])
      |> Map.merge(Deep.data()[:example]),
    additionalProperties: false
  })

  defimpl RequestDecoder,
    for: MongoosePushWeb.Schemas.Request.SendNotification.Deep.MixedNotification do
    alias MongoosePushWeb.Protocols.RequestDecoderHelper

    @spec decode(%Deep.MixedNotification{}) :: MongoosePush.request()
    def decode(schema) do
      %{
        service: RequestDecoderHelper.parse_service(schema.service),
        alert: RequestDecoder.decode(schema.alert),
        data: schema.data
      }
      |> RequestDecoderHelper.add_optional_fields(schema)
    end
  end
end
