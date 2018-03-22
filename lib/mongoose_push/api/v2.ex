defmodule MongoosePush.API.V2 do
  @moduledoc false

  use Maru.Router
  version "v2"

  plug Plug.Parsers,
      pass: ["application/json", "text/json"],
      json_decoder: Poison,
      parsers: [:urlencoded, :json, :multipart]

  params do
    requires  :service,       type: Atom, values: [:fcm, :apns]
    optional  :mode,          type: Atom, values: [:prod, :dev]
    optional  :priority,      type: Atom, values: [:normal, :high]

    # Only for APNS, alert/data independent
    optional  :topic,         type: String

    optional  :alert,         type: Map do
      requires  :body,          type: String
      requires  :title,         type: String
      optional  :badge,         type: Integer
      optional  :click_action,  type: String
      optional  :tag,           type: String
      optional  :sound,         type: String
    end

    # Use raw json value to skip all maru's validators
    optional  :data,          type: &(&1)

    # We need to send at least one of data or alert
    # but it's possible to send both
    at_least_one_of [:alert, :data]
  end

  namespace :notification do
    route_param :device_id do
      post do
        device_id = params.device_id
        case MongoosePush.push(device_id, Map.delete(params, :device_id)) do
          :ok ->
            conn
            |> put_status(200)
            |> json(nil)
          {:error, reason} when is_atom(reason) ->
            conn
            |> put_status(500)
            |> json(%{:details => reason})
          {:error, _reason} ->
            conn
            |> put_status(500)
            |> json(nil)
        end
      end
    end
  end

end
