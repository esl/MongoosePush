defmodule MongoosePush.Config.ConfexProvider do
  @moduledoc """
  """
  @behaviour Distillery.Releases.Config.Provider

  @spec init([any()]) :: :ok
  def init(_opts) do
    all_apps = Application.loaded_applications()

    Enum.each(all_apps, fn {app, _, _} ->
      Confex.resolve_env!(app)
    end)
  end

  @doc """
  Used by `prod.exs` to parse env variables to inet-style IP addresses
  """
  def parse_bind_addr(string_addr) do
    case :inet.parse_address(String.to_charlist(string_addr)) do
      {:ok, value} ->
        {:ok, value}

      {:error, reason} ->
        # Confex requires reason to be string
        {:error, inspect(reason)}
    end
  end
end
