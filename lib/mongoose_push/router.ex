defmodule MongoosePush.Router do
  @moduledoc false

  use Maru.Router
  use MaruSwagger
  require Logger
  @test false

  plug Plug.Logger, log: :debug

  swagger at:         "/swagger.json",
          pretty:     true,
          except:     [:prod],
          force_json: true,

          swagger_inject: [
            basePath: "/",
            schemes:  ["https", "h2"],
            consumes: ["application/json"],
            produces: [
              "application/json",
            ]
          ]

  mount MongoosePush.API.V1
  mount MongoosePush.API.V2

  rescue_from Maru.Exceptions.NotFound do
    conn
    |> put_status(404)
    |> json(%{details: "This is not the endpoint you are looking for."})
  end

  rescue_from Maru.Exceptions.InvalidFormat, as: e do
    conn
    |> put_status(400)
    |> json(%{details: ~s"#{ Exception.message e }"})
  end

  rescue_from Maru.Exceptions.Validation, as: e do
    conn
    |> put_status(400)
    |> json(%{details: ~s"#{ Exception.message e }"})
  end

  rescue_from Maru.Exceptions.MethodNotAllowed do
    conn
    |> put_status(405)
    |> json(nil)
  end

  rescue_from :all, as: e do
    status = Map.get e, :plug_status, 500
    log_level =
        case status >= 500 do
          true  -> :error
          false -> :info
        end
    Logger.log log_level, inspect e
    conn
    |> put_status(status)
    |> json(nil)
  end

end
