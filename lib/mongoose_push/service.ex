defmodule MongoosePush.Service do
  @moduledoc """
  Generic interface for push notifications services.
  """
  @type notification :: term

  @callback push(notification, string, atom) :: :ok | {:error, term}
  @callback prepare_notification(string, MongoosePush.request) :: notification
end
