defmodule MongoosePushWeb.Router do
  use MongoosePushWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :swagger_json do
    plug(:accepts, ["json"])
    plug(OpenApiSpex.Plug.PutApiSpec, module: MongoosePushWeb.ApiSpec)
  end

  scope "/api", MongoosePushWeb do
    pipe_through(:api)

    post("/dummy", DummyController, :handle)
  end

  scope "/" do
    pipe_through(:swagger_json)

    get("/swagger.json", OpenApiSpex.Plug.RenderSpec, [])
  end

  scope "/v1", MongoosePushWeb do
    pipe_through(:api)

    post("/notification", APIv1.NotificationController, :send)
  end
end
