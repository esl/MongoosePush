defmodule MongoosePushWeb.Router do
  use MongoosePushWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", MongoosePushWeb do
    pipe_through(:api)

    post("/dummy", DummyController, :handle)
  end
end
