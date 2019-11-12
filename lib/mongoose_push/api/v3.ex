defmodule MongoosePush.API.V3 do
  @moduledoc false

  use Maru.Router
  version("v3")

  plug(Plug.Parsers,
    pass: ["application/json", "text/json"],
    json_decoder: Poison,
    parsers: [:urlencoded, :json, :multipart]
  )

  desc "description" do
    detail "details of described request"

    responses do
      status 200, desc: "OK"
      status 400, desc: "{"reason" : "invalid_request"|"no_matching_pool"} - the request was invalid"
      status 410, desc: "{"reason" : "unregistered"} - the device was not registered"
      status 413, desc: "{"reason" : "payload_too_large"} - the payload was too large"
      status 429, desc: "{"reason" : "too_many_requests"} - there were too many requests to the server"
      status 503, desc: "{"reason" : "service_internal"|"internal_config"|"unspecified"} - the internal service or configuration error occured"
      status 520, desc: "{"reason" : "unspecified"} - the unknown error occured"
      status 500, desc: "{"reason" : reason} - the server internal error occured"
    end
  end

  params do
    requires(:service, type: Atom, values: [:fcm, :apns])
    optional(:mode, type: Atom, values: [:prod, :dev])
    optional(:priority, type: Atom, values: [:normal, :high])
    optional(:time_to_live, type: Integer)
    optional(:mutable_content, type: Boolean, default: false)

    # Only for APNS, alert/data independent
    optional(:topic, type: String)

    optional :alert, type: Map do
      requires(:body, type: String)
      requires(:title, type: String)
      optional(:badge, type: Integer)
      optional(:click_action, type: String)
      optional(:tag, type: String)
      optional(:sound, type: String)
    end

    # Use raw json value to skip all maru's validators
    optional(:data, type: & &1)

    # We need to send at least one of data or alert
    # but it's possible to send both
    at_least_one_of([:alert, :data])
  end

  namespace :notification do
    route_param :device_id do
      post do
        device_id = params.device_id

        {status, payload} =
          device_id
          |> MongoosePush.push(Map.delete(params, :device_id))
          |> MongoosePush.API.V3.ResponseEncoder.to_status()

        conn
        |> put_status(status)
        |> json(payload)
      end
    end
  end
end
