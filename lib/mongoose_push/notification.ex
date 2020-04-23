defmodule MongoosePush.Notification do
  alias MongoosePushWeb.Schemas.Request

  @moduledoc false
  @type push_request ::
          %Request.SendNotification.Flat{}
          | %Request.SendNotification.Deep.Alert{}
          | %Request.SendNotification.Deep.Data{}

  @callback push(String.t(), MongoosePush.request() | push_request) ::
              :ok | {:error, MongoosePush.Service.error()} | {:error, MongoosePush.error()}
end
