defmodule MongoosePush.Service do
  @moduledoc """
  Generic interface for push notifications services.
  """

  @type notification :: term

  @callback push(Service.notification(), String.t(), atom(),
                 Service.options()) :: :ok | {:error, term}
  @callback prepare_notification(String.t(), MongoosePush.request) ::
    Service.notification
  @callback workers({atom, Keyword.t()} | nil) :: list(Supervisor.Spec.spec())
end
