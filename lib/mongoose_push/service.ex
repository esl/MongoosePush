defmodule MongoosePush.Service do
  @moduledoc """
  Generic interface for push notifications services.
  """
  alias MongoosePush.Application

  @type notification :: term
  @type options :: [option]

  @typep option :: {:timeout, integer()}

  @callback push(notification(), String.t(), atom(), options()) ::
              :ok | {:error, term}
  @callback prepare_notification(String.t(), MongoosePush.request(), Application.pool_name()) ::
              notification()
  @callback supervisor_entry([Application.pool_definition()] | nil) :: {module(), term()}
  @callback choose_pool(MongoosePush.mode()) :: Application.pool_name() | nil
end
