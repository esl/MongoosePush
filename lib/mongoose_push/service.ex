defmodule MongoosePush.Service do
  @moduledoc """
  Generic interface for push notifications services.
  """
  alias MongoosePush.Application

  @type notification :: term
  @type options :: [Keyword.t()]

  @type error_type ::
          :invalid_request
          | :internal_config
          | :auth
          | :unregistered
          | :too_many_requests
          | :unspecified
          | :service_internal
          | :payload_too_large

  @type error_reason :: atom

  @typedoc """
  Error tuple with unified internal representation and exact reason returned by service
  """
  @type error :: {error_type, error_reason}

  @callback push(notification(), String.t(), Application.pool_name(), options()) ::
              :ok | {:error, term}
  @callback prepare_notification(String.t(), MongoosePush.request(), Application.pool_name()) ::
              notification()
  @callback supervisor_entry([Application.pool_definition()] | nil) :: {module(), term()}
  @callback choose_pool(MongoosePush.mode()) :: Application.pool_name() | nil
  @callback unify_error(error_reason) :: error
end
