defmodule MongoosePushWeb.ApiSpec do
  alias OpenApiSpex.{OpenApi, Server, Info, Paths}
  alias MongoosePushWeb.{Endpoint, Router}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        # Populate the Server info from a phoenix endpoint
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "MongoosePush",
        version: "1.0"
      },
      # populate the paths from a phoenix router
      paths: Paths.from_router(Router)
    }
    |> OpenApiSpex.resolve_schema_modules() # discover request/response schemas from path specs
  end
end
