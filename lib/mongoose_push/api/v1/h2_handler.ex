defmodule MongoosePush.API.V1.H2Handler do
  @moduledoc """
    Module for handling internal responses to V1 HTTP2 codes
  """
  @behaviour MongoosePush.API

  @spec to_status(:ok | {:error, term}) ::
    {non_neg_integer, %{details: atom | String.t()} | nil}
  def to_status(return_val) do
    MongoosePush.API.V2.H2Handler.to_status(return_val)
  end
end
