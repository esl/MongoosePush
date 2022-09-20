defmodule MongoosePush.Config.Provider.Confex do
  @moduledoc false
  @behaviour Config.Provider

  @ignored_apps [:kernel, :stdlib]

  @impl true
  def init(opts), do: opts

  @impl true
  def load(config, _opts) do
    new_config =
      Application.loaded_applications()
      |> Enum.reject(fn {app, _, _} -> app in @ignored_apps end)
      |> Enum.map(fn {app, _, _} -> {app, fetch_envs(app)} end)

    Config.Reader.merge(config, new_config)
  end

  @spec fetch_envs(Application.app()) :: [{Application.key(), Application.value()}]
  defp fetch_envs(app) do
    Application.get_all_env(app)
    |> Enum.map(fn {key, _} -> {key, Confex.fetch_env!(app, key)} end)
  end
end
