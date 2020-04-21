defmodule MongoosePushBehaviour do
  @moduledoc false
  @callback push(String.t(), MongoosePush.request()) ::
              :ok | {:error, Service.error()} | {:error, MongoosePush.error()}
end
