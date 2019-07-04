defmodule MongoosePush.Service do
  @moduledoc """
  Generic interface for push notifications services.
  """
  alias MongoosePush.Application

  @type notification :: term

  @callback push(Service.notification(), String.t(), atom(), Service.options()) ::
              :ok | {:error, term}
  @callback prepare_notification(String.t(), MongoosePush.request(), Application.pool_name()) ::
              Service.notification()
  @callback supervisor_entry([Application.pool_definition()] | nil) :: {module(), term()}
  @callback choose_pool(MongoosePush.mode()) :: Application.pool_name() | nil
end
