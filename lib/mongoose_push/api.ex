defmodule MongoosePush.API do

  @spec to_status(:ok | {:error, term}) ::
    {non_neg_integer, %{details: atom | String.t} | nil}
  def to_status(:ok), do: {200, nil}
  def to_status({:error, :unable_to_connect}) do
    {503, %{:details => "Please try again later"}}
  end
  def to_status({:error, reason}) when is_atom(reason) do
    {500, %{:details => reason}}
  end
  def to_status({:error, reason}) do
    {500, nil}
  end
end
