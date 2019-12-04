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
end
