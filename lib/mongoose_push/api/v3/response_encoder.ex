defmodule MongoosePush.API.V3.ResponseEncoder do
  @moduledoc """
  Module for handling internal responses to V3 HTTP2 codes
  """
  @behaviour MongoosePush.API
  alias MongoosePush.Service

  @spec to_status(:ok | {:error, Service.error()} | {:error, MongoosePush.error()}) ::
          {non_neg_integer, %{reason: atom | String.t()} | nil}
  def to_status(:ok), do: {200, nil}

  def to_status({:error, {type, reason}}) when is_atom(reason) do
    {status, error_reason} =
      case {type, reason} do
        {:invalid_request, _} -> {400, type}
        {:unregistered, _} -> {410, type}
        {:payload_too_large, _} -> {413, type}
        {:too_many_requests, _} -> {429, type}
        {:service_internal, _} -> {503, type}
        {:auth, _} -> {503, :service_internal}
        {:internal_config, _} -> {503, type}
        {:unspecified, _} -> {520, type}
        {:generic, _} -> {generic_status(reason), reason}
      end

    {status, %{:reason => error_reason}}
  end

  def to_status({:error, _reason}) do
    {500, nil}
  end

  defp generic_status(:no_matching_pool), do: 400
  defp generic_status(:invalid_notification), do: 400

  # The push notification service could not be reached or did not respond
  defp generic_status(reason)
       when reason in [
              :unable_to_connect,
              :connection_lost,
              :request_timeout,
              :too_many_concurrent_requests
            ],
       do: 503

  defp generic_status(_reason), do: 500
end
