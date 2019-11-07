defmodule MongoosePush.API.V1.ResponseEncoder do
  @moduledoc """
  Module for handling internal responses to V1 HTTP2 codes
  """
  @behaviour MongoosePush.API
  alias MongoosePush.Service

  @spec to_status(:ok | {:error, Service.error()} | {:error, MongoosePush.error()}) ::
          {non_neg_integer, %{details: atom | String.t()} | nil}

  def to_status(return_val) do
    MongoosePush.API.V2.ResponseEncoder.to_status(return_val)
  end
end
