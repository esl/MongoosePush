defmodule MongoosePushWeb.Router do
  use MongoosePushWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", MongoosePushWeb do
    pipe_through(:api)

    post("/simple", ApiController, :post)
  end
end
