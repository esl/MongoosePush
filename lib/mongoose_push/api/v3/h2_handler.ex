defmodule MongoosePush.API.V3.H2Handler do
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
        :invalid_request ->
          461
        :auth ->
          462
        :unregistered ->
          463
        :unspecified ->
          464
        :service_internal ->
          465
        :internal_config ->
          561
        :too_many_requests ->
          562
        :payload_too_large ->
          563
        :generic ->
          564
      end
    {return_code, %{:details => reason}}
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
