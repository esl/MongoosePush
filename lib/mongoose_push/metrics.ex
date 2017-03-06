defmodule MongoosePush.Metrics do
  use Elixometer

  def update(return_value, metric_prefix, value \\ 1) do
    case return_value do
      :ok ->
        increment(metric_prefix <> ".success", value)
      {:error, reason} when is_atom(reason) ->
        increment(metric_prefix <> ~s".error.#{reason}", value)
        increment(metric_prefix <> ~s".error.all", value)
        {:error, reason}
      {:error, _reason} ->
        increment(metric_prefix <> ~s".error.all", value)
        increment(metric_prefix <> ".error.unknown", value)
    end
    return_value
  end

  defp increment(metric, value) do
    update_counter(metric <> ".count", value)
    update_spiral(metric <> ".qps", value)
  end

end
