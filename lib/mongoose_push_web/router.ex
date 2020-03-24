defmodule MongoosePushWeb.Router do
  use MongoosePushWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug OpenApiSpex.Plug.PutApiSpec, module: MongoosePushWeb.ApiSpec
  end

  scope "/api", MongoosePushWeb do
    pipe_through(:api)

    post("/dummy", DummyController, :handle)
  end

  scope "/v1" do
    pipe_through(:api)

    get("/swagger.json", OpenApiSpex.Plug.RenderSpec, [])
    post("/notification", MongoosePushWeb.APIv1Controller, :handle)
  end
end
