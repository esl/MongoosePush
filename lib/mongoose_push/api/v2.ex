defmodule MongoosePush.API.V2 do
  @moduledoc false

  use Maru.Router
  version "v2"

  plug Plug.Parsers,
      pass: ["application/json", "text/json"],
      json_decoder: Poison,
      parsers: [:urlencoded, :json, :multipart]

  params do
    requires  :service,         type: Atom, values: [:fcm, :apns]
    optional  :mode,            type: Atom, values: [:prod, :dev]
    optional  :priority,        type: Atom, values: [:normal, :high]
    optional  :mutable_content, type: Boolean, default: false

    # Only for APNS, alert/data independent
    optional  :topic,           type: String

    optional  :alert,           type: Map do
      requires  :body,            type: String
      requires  :title,           type: String
      optional  :badge,           type: Integer
      optional  :click_action,    type: String
      optional  :tag,             type: String
      optional  :sound,           type: String
    end

    # Use raw json value to skip all maru's validators
    optional  :data,            type: &(&1)

    # We need to send at least one of data or alert
    # but it's possible to send both
    at_least_one_of [:alert, :data]
  end

  namespace :notification do
    route_param :device_id do
      post do
        device_id = params.device_id

        {status, payload} =
          device_id
          |> MongoosePush.push(Map.delete(params, :device_id))
          |> MongoosePush.API.to_status

        conn
          |> put_status(status)
          |> json(payload)
      end
    end
  end

end
