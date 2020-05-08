defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertNotification do
  require OpenApiSpex
  alias MongoosePushWeb.Protocols.RequestDecoder
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.AlertNotification",
    description: "In this request alert field is mandatory.",
    type: :object,
    properties: Deep.base()[:properties],
    required: Deep.base()[:required] ++ Deep.alert()[:required],
    example: Map.merge(Deep.base()[:example], Deep.alert()[:example]),
    additionalProperties: false
  })

  defimpl RequestDecoder,
    for: MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertNotification do
    def decode(schema) do
      %{
        service: String.to_atom(schema.service),
        alert: RequestDecoder.decode(schema.alert)
      }
      |> add_optional_fields(schema)
    end

    defp add_optional_fields(push_request, schema) do
      opt_keys = [:data, :mutable_content, :mode, :priority, :tags, :time_to_live, :topic]

      Enum.reduce(opt_keys, push_request, fn x, acc ->
        case Map.get(schema, x) do
          nil -> acc
          val -> Map.put(acc, x, maybe_parse_to_atom(x, val))
        end
      end)
    end

    defp maybe_parse_to_atom(:mode, val), do: parse_mode(val)
    defp maybe_parse_to_atom(:priority, val), do: parse_priority(val)
    defp maybe_parse_to_atom(_key, val), do: val

    defp parse_mode("prod"), do: :prod
    defp parse_mode("dev"), do: :dev

    defp parse_priority("normal"), do: :normal
    defp parse_priority("high"), do: :high
  end
end
