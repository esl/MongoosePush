defmodule MongoosePush.API do

  @spec to_status(:ok | {:error, term}) ::
    {non_neg_integer, %{details: atom | String.t} | nil}
  def to_status(:ok), do: {200, nil}
  def to_status({:error, :unable_to_connect}) do
    {503, %{:details => "Please try again later"}}
  end
  def to_status({:error, reason}) when is_atom(reason) do
    try do
      code = Plug.Conn.Status.code(reason)
      reason_phrase = Plug.Conn.Status.reason_phrase(code)
      {code, %{:details => reason_phrase}}
    catch
      _, _ -> # We really don't care what happened here, we have to return something
        {500, %{:details => reason}}
    end
  end
  def to_status({:error, reason}) when is_binary(reason) do
    {400, reason}
  end
  def to_status({:error, _reason}) do
    {500, nil}
  end

end
