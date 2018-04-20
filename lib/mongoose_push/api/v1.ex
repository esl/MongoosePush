defmodule MongoosePush.API.V1 do
  @moduledoc false

  use Maru.Router
  version "v1"

  plug Plug.Parsers,
      pass: ["application/json", "text/json"],
      json_decoder: Poison,
      parsers: [:urlencoded, :json, :multipart]

  params do
    requires  :service,       type: Atom, values: [:fcm, :apns]
    requires  :body,          type: String
    requires  :title,         type: String
    optional  :badge,         type: Integer
    optional  :click_action,  type: String
    optional  :tag,           type: String
    optional  :topic,         type: String
    # For `data`, use raw json value to skip all maru's validators
    optional  :data,          type: &(&1)
    optional  :mode,          type: Atom, values: [:prod, :dev]
  end

  namespace :notification do
    route_param :device_id do
      post do
        device_id = params.device_id

        notification =
          params
          |> Map.delete(:device_id)
          |> transform_alert()

        {status, payload} =
          device_id
          |> MongoosePush.push(notification)
          |> MongoosePush.API.to_status

        conn
          |> put_status(status)
          |> json(payload)
      end
    end
  end

  defp transform_alert(params) do
    alert_keys = [:body, :title, :badge, :click_action, :tag]

    alert =
      alert_keys
      |> Enum.map(fn(key) -> {key, params[key]} end)
      |> Enum.filter(fn({_key, value}) -> value != nil end)
      |> Enum.into(%{})

    params
    |> Map.drop(alert_keys)
    |> Map.put(:alert, alert)
  end

end
