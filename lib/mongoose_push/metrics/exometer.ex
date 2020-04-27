defmodule MongoosePush.Metrics.Exometer do
  @moduledoc """
  This module provides some utility macros that simplify the use of Elixometer.
  """

  defmacro __using__(_opts) do
    quote do
      use Elixometer
      require MongoosePush.Metrics.Exometer, as: Metrics
    end
  end

  @doc """
  Updates metric (spiral) by given value. The metrics name is
  generated based on given prefix and the return value of the tested function.
  Provided return value of `:ok` is counted as succeses, while
  `{:error, reason :: term}` as error `reason`.
  """
  defmacro update_success(return_value, mtype, metric, value \\ 1) do
    quote bind_quoted: [mtype: mtype, metric: metric, value: value, return_value: return_value],
          unquote: true do
      alias MongoosePush.Metrics.Exometer, as: Metrics

      final_metrics = [Metrics.name(unquote(mtype), unquote(metric), [:success])]

      for final_metric <- final_metrics do
        Metrics.update_metric(unquote(mtype), final_metric, unquote(value))
      end

      return_value
    end
  end

  defmacro update_error(return_value, mtype, metric, value \\ 1) do
    quote bind_quoted: [mtype: mtype, metric: metric, value: value, return_value: return_value],
          unquote: true do
      alias MongoosePush.Metrics.Exometer, as: Metrics

      {:error, reason} = return_value

      general_metric = Metrics.name(unquote(mtype), unquote(metric), [:error, :all])

      main_metric =
        case is_atom(reason) do
          true ->
            Metrics.name(unquote(mtype), unquote(metric), [:error, reason])

          false ->
            Metrics.name(unquote(mtype), unquote(metric), [:error, :unknown])
        end

      final_metrics = [main_metric, general_metric]

      for final_metric <- final_metrics do
        Metrics.update_metric(unquote(mtype), final_metric, unquote(value))
      end

      return_value
    end
  end

  defmacro update_metric(:spiral, metric, value) do
    quote bind_quoted: [metric: metric, value: value], unquote: true do
      Elixometer.update_spiral(metric, value)
    end
  end

  defmacro update_metric(:timer, metric, value) do
    quote bind_quoted: [metric: metric, value: value], unquote: true do
      Elixometer.Updater.timer(metric, :microsecond, value)
    end
  end

  defmacro name(type, prefix, suffix) do
    quote bind_quoted: [type: type, prefix: prefix, suffix: suffix],
          unquote: true do
      unquote(List.flatten([:mongoose_push, :"#{type}s", prefix, suffix]))
      |> Enum.map(&Atom.to_string/1)
    end
  end
end
