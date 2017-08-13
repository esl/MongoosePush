defmodule MongoosePush.Metrics do
  @moduledoc """
  This module provides some utility macros that simplify use of
  Elixometer.
  """

  defmacro __using__(_opts) do
    quote do
      use Elixometer
      require MongoosePush.Metrics, as: Metrics
    end
  end

  @doc """
  Updates metric (spiral) by given value. The metrics name is
  generated based on given prefix and the return value of the tested function.
  Provided return value of `:ok` is counted as succeses, while
  `{:error, reason :: term}` as error `reason`.
  """
  defmacro update(return_value, mtype, metric, value \\ 1) do
    quote [bind_quoted: [mtype: mtype, metric: metric, value: value,
                        return_value: return_value], unquote: true] do
      alias MongoosePush.Metrics
      final_metrics =
        case return_value do
          :ok ->
            [Metrics.name(unquote(mtype), unquote(metric), [:success])]
          {:error, reason} ->
            general_metric =
              Metrics.name(unquote(mtype), unquote(metric), [:error, :all])

            main_metric =
              case is_atom(reason) do
                true ->
                  Metrics.name(unquote(mtype), unquote(metric),
                               [:error, reason])
                false ->
                  Metrics.name(unquote(mtype), unquote(metric),
                               [:error, :unknown])
              end
            [main_metric, general_metric]
        end

      for final_metric <- final_metrics do
        unquote(:"update_#{mtype}")(final_metric, value)
      end
      return_value
    end
  end

  defmacro name(type, prefix, suffix) do
    quote [bind_quoted: [type: type, prefix: prefix, suffix: suffix],
           unquote: true] do
      unquote(List.flatten([:mongoose_push, :"#{type}s", prefix, suffix]))
      |> Enum.map(&Atom.to_string/1)
    end
  end

end
