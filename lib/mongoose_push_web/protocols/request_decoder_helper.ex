defmodule MongoosePushWeb.Protocols.RequestDecoderHelper do
  def add_optional_fields(push_request, schema) do
    opt_keys = [:mutable_content, :mode, :priority, :tags, :time_to_live, :topic]

    Enum.reduce(opt_keys, push_request, fn x, acc ->
      case Map.get(schema, x) do
        nil -> acc
        val -> Map.put(acc, x, maybe_parse_to_atom(x, val))
      end
    end)
  end

  def maybe_parse_to_atom(:mode, val), do: parse_mode(val)
  def maybe_parse_to_atom(:priority, val), do: parse_priority(val)
  def maybe_parse_to_atom(_key, val), do: val

  defp parse_mode("prod"), do: :prod
  defp parse_mode("dev"), do: :dev

  defp parse_priority("normal"), do: :normal
  defp parse_priority("high"), do: :high
end
