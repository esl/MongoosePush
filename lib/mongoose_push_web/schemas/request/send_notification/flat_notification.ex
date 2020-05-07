defmodule MongoosePushWeb.Schemas.Request.SendNotification.FlatNotification do
  require OpenApiSpex
  alias MongoosePushWeb.Schemas.Request
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.FlatNotification",
    description: "Push notification request schema",
    type: :object,
    properties: %{
      service: %Schema{
        type: :string,
        description: "Push notification service",
        format: :text,
        enum: ["fcm", "apns"]
      },
      body: %Schema{type: :string, description: "Body of the notification", format: :text},
      title: %Schema{type: :string, description: "Title of the notification", format: :text},
      badge: %Schema{type: :integer, format: :int32},
      click_action: %Schema{type: :string},
      tag: %Schema{type: :string},
      topic: %Schema{type: :string},
      data: %Schema{
        type: :object,
        description:
          "Custom key-values pairs of the message's payload. " <>
            "The FCM request with nested data can end up with error."
      },
      mode: %Schema{type: :string, enum: ["prod", "dev"]}
    },
    required: [:service, :body, :title],
    example: %{
      "service" => "apns",
      "body" => "A message from someone",
      "title" => "Notification title",
      "badge" => 7,
      "click_action" => ".SomeApp.Handler.action",
      "tag" => "info",
      "topic" => "com.someapp",
      "data" => %{
        "custom" => "data fields",
        "some_id" => 345_645_332,
        "nested" => %{"fields" => "allowed"}
      },
      "mode" => "prod"
    },
    additionalProperties: false
  })

  defimpl MongoosePushWeb.Protocols.RequestDecoder,
    for: Request.SendNotification.FlatNotification do
    @spec decode(%Request.SendNotification.FlatNotification{}) :: MongoosePush.request()
    def decode(schema) do
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

    defp add_optional_fields(push_request, schema) do
      opt_keys = [:data, :mode, :topic]

      Enum.reduce(opt_keys, push_request, fn x, acc ->
        case Map.get(schema, x) do
          nil -> acc
          val -> Map.put(acc, x, maybe_parse_to_atom(x, val))
        end
      end)
    end

    defp add_optional_alert_fields(push_request, schema) do
      opt_alert_keys = [:badge, :click_action, :tag]

      Enum.reduce(opt_alert_keys, push_request, fn x, acc ->
        case Map.get(schema, x) do
          nil -> acc
          val -> Kernel.update_in(acc, [:alert, x], fn _ -> val end)
        end
      end)
    end

    defp maybe_parse_to_atom(:mode, val), do: parse_mode(val)
    defp maybe_parse_to_atom(_key, val), do: val

    defp parse_mode("prod"), do: :prod
    defp parse_mode("dev"), do: :dev
  end
end
