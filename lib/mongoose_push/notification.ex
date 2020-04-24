defmodule MongoosePush.Notification do
  @moduledoc false
  @callback push(String.t(), MongoosePush.request()) ::
              :ok | {:error, MongoosePush.Service.error()} | {:error, MongoosePush.error()}
end
