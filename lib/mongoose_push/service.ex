defmodule MongoosePush.Service do
  @moduledoc """
  Generic interface for push notifications services.
  """

  @type notification :: term
  @type options :: [option]

  @typep option :: {:timeout, integer()}

  @callback push(notification(), String.t(), atom(), options()) ::
              :ok | {:error, term}
  @callback prepare_notification(String.t(), MongoosePush.request()) ::
              notification()
  @callback workers({atom, Keyword.t()} | nil) :: list(Supervisor.Spec.spec())
end
