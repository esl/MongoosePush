defmodule MongoosePush.Service do
  @moduledoc """
  Generic interface for push notifications services.
  """
  alias MongoosePush.Application

  @type notification :: term
  @type options :: [Keyword.t()]

  @callback push(notification(), String.t(), Application.pool_name(), options()) ::
              :ok | {:error, term}
  @callback prepare_notification(String.t(), MongoosePush.request(), Application.pool_name()) ::
              notification()
  @callback supervisor_entry([Application.pool_definition()] | nil) :: {module(), term()}
  @callback choose_pool(MongoosePush.mode()) :: Application.pool_name() | nil
end
