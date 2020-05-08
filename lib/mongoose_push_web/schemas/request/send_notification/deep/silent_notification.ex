defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.SilentNotification do
  require OpenApiSpex
  alias MongoosePushWeb.Protocols.RequestDecoder
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.SilentNotification",
    description: "In this request data field is mandatory.",
    type: :object,
    properties: Deep.base()[:properties],
    required: Deep.base()[:required] ++ Deep.data()[:required],
    example: Map.merge(Deep.base()[:example], Deep.data()[:example]),
    additionalProperties: false
  })

  defimpl RequestDecoder,
    for: MongoosePushWeb.Schemas.Request.SendNotification.Deep.SilentNotification do
    def decode(schema) do
      %{
        service: String.to_atom(schema.service),
        data: schema.data
      }
      |> add_optional_fields(schema)
      |> maybe_add_alert(schema)
    end

    defp add_optional_fields(push_request, schema) do
      opt_keys = [:mutable_content, :mode, :priority, :tags, :time_to_live, :topic]

      Enum.reduce(opt_keys, push_request, fn x, acc ->
        case Map.get(schema, x) do
          nil -> acc
          val -> Map.put(acc, x, maybe_parse_to_atom(x, val))
        end
      end)
    end

    defp maybe_add_alert(push_request, %{alert: nil} = schema), do: push_request

    defp maybe_add_alert(push_request, schema),
      do: Map.put(push_request, :alert, RequestDecoder.decode(schema.alert))

    defp maybe_parse_to_atom(:mode, val), do: parse_mode(val)
    defp maybe_parse_to_atom(:priority, val), do: parse_priority(val)
    defp maybe_parse_to_atom(_key, val), do: val

    defp parse_mode("prod"), do: :prod
    defp parse_mode("dev"), do: :dev

    defp parse_priority("normal"), do: :normal
    defp parse_priority("high"), do: :high
  end
end
