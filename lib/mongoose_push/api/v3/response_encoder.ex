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
    return_code =
      case type do
        :invalid_request -> 400
        :unregistered -> 410
        :payload_too_large -> 413
        :too_many_requests -> 429
        :auth -> 503
        :service_internal -> 503
        :internal_config -> 503
        :unspecified -> 520
        :generic -> 400
      end

    {return_code, %{:reason => type}}
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
