defmodule MongoosePushWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :mongoose_push

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug MongoosePushWeb.Router
end
