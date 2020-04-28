defmodule MongoosePush.Metrics.Exometer do
  @moduledoc """
  This module provides an Elixometer implementation to the `MongoosePush.Metrics` behaviour
  """
  use Elixometer

  @behaviour MongoosePush.Metrics

  @doc """
  Updates metric (spiral) by given value. The metrics name is
  generated based on given prefix and the return value of the tested function.
  Provided return value of `:ok` is counted as succeses, while
  `{:error, reason :: term}` as error `reason`.
  """
  def update_success(return_value, mtype, metric, value \\ 1) do
    final_metrics = [name(mtype, metric, [:success])]

    for final_metric <- final_metrics do
      update_metric(mtype, final_metric, value)
    end

    return_value
  end

  def update_error(return_value, mtype, metric, value \\ 1) do
    {:error, reason} = return_value

    general_metric = name(mtype, metric, [:error, :all])

    main_metric =
      case is_atom(reason) do
        true ->
          name(mtype, metric, [:error, reason])

        false ->
          name(mtype, metric, [:error, :unknown])
      end

    final_metrics = [main_metric, general_metric]

    for final_metric <- final_metrics do
      update_metric(mtype, final_metric, value)
    end

    return_value
  end

  def update_metric(:spiral, metric, value) do
    Elixometer.update_spiral(metric, value)
  end

  def update_metric(:timer, metric, value) do
    Elixometer.Updater.timer(metric, :microsecond, value)
  end

  defp name(type, prefix, suffix) do
    List.flatten([:mongoose_push, :"#{type}s", prefix, suffix])
    |> Enum.map(&Atom.to_string/1)
  end
end
