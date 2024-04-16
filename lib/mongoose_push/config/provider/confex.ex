defmodule MongoosePush.Config.Provider.Confex do
  @moduledoc false
  @behaviour Config.Provider

  @impl true
  def init(opts), do: opts

  @impl true
  def load(config, _opts) do
    Confex.Resolver.resolve!(config)
  end
end
