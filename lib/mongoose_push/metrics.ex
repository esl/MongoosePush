defmodule MongoosePush.Metrics do
  @moduledoc """
  This module provides some utility functions that simplify use of
  Elixometer.
  """
  use Elixometer

  @doc """
  Updates metrics (counter and spiral) by given value. The metrics name is
  generated based on given prefix and the return value of the tested function.
  Provided return value of `:ok` is counted as succeses, while
  `{:error, reason :: term}` as error `reason`.
  """
  @spec update(:ok | {:error, term}, String.t, integer) :: :ok | {:error, term}
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
