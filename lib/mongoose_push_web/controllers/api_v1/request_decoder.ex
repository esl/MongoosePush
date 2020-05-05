defmodule MongoosePushWeb.APIv1.RequestDecoder do
  alias MongoosePushWeb.Schemas.Request

  @spec decode(Request.SendNotification.FlatNotification.t()) :: MongoosePush.request()
  def decode(%Request.SendNotification.FlatNotification{} = schema) do
    _push_request =
      %{
        service: String.to_atom(schema.service),
        alert: %{
          body: schema.body,
          title: schema.title
        }
      }
      |> add_optional_fields(schema)
      |> add_optional_alert_fields(schema)
  end

  @spec add_optional_fields(MongoosePush.request(), %Request.SendNotification.FlatNotification{}) ::
          MongoosePush.request()
  defp add_optional_fields(push_request, schema) do
    opt_keys = [:data, :mode, :topic]

    Enum.reduce(opt_keys, push_request, fn x, acc ->
      case Map.get(schema, x) do
        nil -> acc
        val -> Map.put(acc, x, maybe_convert_to_atom(x, val))
      end
    end)
  end

  @spec add_optional_alert_fields(
          MongoosePush.request(),
          %Request.SendNotification.FlatNotification{}
        ) ::
          MongoosePush.request()
  defp add_optional_alert_fields(push_request, schema) do
    opt_alert_keys = [:badge, :click_action, :tag]

    Enum.reduce(opt_alert_keys, push_request, fn x, acc ->
      case Map.get(schema, x) do
        nil -> acc
        val -> Kernel.update_in(acc, [:alert, x], fn _ -> val end)
      end
    end)
  end

  @spec maybe_convert_to_atom(atom(), String.t() | map()) :: atom() | String.t() | map()
  defp maybe_convert_to_atom(:mode, val), do: String.to_atom(val)
  defp maybe_convert_to_atom(_key, val), do: val
end
