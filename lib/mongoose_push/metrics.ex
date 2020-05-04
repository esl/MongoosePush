defmodule MongoosePush.Metrics do
  @moduledoc """
  This module defines the behaviour for metrics collectors.
  """

  defmacro __using__(_opts) do
    quote do
      use Elixometer
      require MongoosePush.Metrics, as: Metrics
    end
  end

  @type return_value :: :ok | {:error, any}
  @type metric_type :: :spiral | :timer
  @callback update_success(metric_type, atom, any) :: :ok
  @callback update_error(return_value, metric_type, atom, any) :: {:error, any}
  @callback update_metric(metric_type, atom, any) :: :ok
end
