defmodule MongoosePush.API do
  @callback to_status(:ok | {:error, term}) ::
              {non_neg_integer, %{details: atom | String.t()} | %{reason: atom | String.t()} | nil}
end
