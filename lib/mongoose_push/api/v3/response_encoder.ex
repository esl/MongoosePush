defmodule MongoosePush.API.V3.ResponseEncoder do
  @moduledoc """
  Module for handling internal responses to V3 HTTP2 codes
  """
  @behaviour MongoosePush.API
  alias MongoosePush.Service

  @spec to_status(:ok | {:error, Service.error()} | {:error, MongoosePush.error()}) ::
          {non_neg_integer, %{details: atom | String.t()} | nil}
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
        {:generic, :no_matching_pool} -> {400, reason}
        {:generic, _} -> {500, reason}
        {:unspecified, _} -> {500, reason}
      end

    {status, %{:reason => error_reason}}
  end

  def to_status({:error, reason}) when is_atom(reason) do
    try do
      code = Plug.Conn.Status.code(reason)
      reason_phrase = Plug.Conn.Status.reason_phrase(code)
      {code, %{:details => reason_phrase}}
    catch
      # We really don't care what happened here, we have to return something
      _, _ ->
        {500, %{:details => reason}}
    end
  end

  def to_status({:error, _reason}) do
    {500, nil}
  end
end
