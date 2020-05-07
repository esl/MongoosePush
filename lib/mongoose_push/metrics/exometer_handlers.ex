defmodule MongoosePush.Metrics.ExometerHandlers do
  @moduledoc """
  Module responsible for updating `Elixometer` metrics
  """

  use Elixometer

  @behaviour MongoosePush.Telemetry

  def event_names do
    [
      [:mongoose_push, :notification, :send],
      [:mongoose_push, :supervisor, :init],
      [:mongoose_push, :apns, :state, :init],
      [:mongoose_push, :apns, :state, :terminate],
      [:mongoose_push, :apns, :state, :get_default_topic]
    ]
  end

  def handle_event(
        [:mongoose_push, :notification, :send],
        measurements,
        metadata = %{:status => :success},
        _
      ) do
    update_success(:spiral, [:push, metadata.service, metadata.mode])

    update_success(
      :timer,
      [:push, metadata.service, metadata.mode],
      measurements.time
    )

    update_metric(:timer, "mongoose_push.push", measurements.time)

    :ok
  end

  def handle_event(
        [:mongoose_push, :notification, :send],
        measurements,
        metadata = %{:status => :error},
        _
      ) do
    type = Map.get(metadata, :type)

    push_result =
      case type do
        nil ->
          {:error, metadata.reason}

        _ ->
          {:error, {type, metadata.reason}}
      end

    push_result
    |> update_error(:spiral, [:push, metadata.service, metadata.mode])
    |> update_error(:timer, [:push, metadata.service, metadata.mode], measurements.time)

    update_metric(:timer, "mongoose_push.push", measurements.time)

    :ok
  end

  def handle_event([:mongoose_push, :apns, :state, :init], _, _, _) do
    :ok
  end

  def handle_event([:mongoose_push, :apns, :state, :terminate], _, _, _) do
    :ok
  end

  def handle_event([:mongoose_push, :apns, :state, :get_default_topic], _, _, _) do
    :ok
  end

  def handle_event([:mongoose_push, :supervisor, :init], _, _, _) do
    :ok
  end

  defp update_success(mtype, metric, value \\ 1) do
    final_metrics = [name(mtype, metric, [:success])]

    for final_metric <- final_metrics do
      update_metric(mtype, final_metric, value)
    end

    :ok
  end

  defp update_error(return_value, mtype, metric, value \\ 1) do
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

  defp update_metric(:spiral, metric, value) do
    Elixometer.update_spiral(metric, value)
  end

  defp update_metric(:timer, metric, value) do
    Elixometer.Updater.timer(metric, :microsecond, value)
  end

  defp name(type, prefix, suffix) do
    List.flatten([:mongoose_push, :"#{type}s", prefix, suffix])
    |> Enum.map(&Atom.to_string/1)
  end
end
