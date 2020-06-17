defmodule MongoosePush.Logger.JSON do
  @moduledoc """
  JSON log formatter
  """

  import MongoosePush.Logger.Common

  def format(level, message, {date, time}, metadata) do
    date_f = Logger.Formatter.format_date(date)
    time_f = Logger.Formatter.format_time(time)

    # Change format of a logging place for readability and compatibility with `:logger` standard
    module = Keyword.get(metadata, :module)
    function = Keyword.get(metadata, :function)
    line = Keyword.get(metadata, :line)
    pid = Keyword.get(metadata, :pid)
    what = Keyword.get(metadata, :what)

    custom_metadata =
      metadata
      |> Keyword.drop([:module, :function, :line, :pid, :mfa, :time, :gl, :what])
      |> flatten_metadata()
      |> Enum.reduce(%{}, fn {key, val}, acc -> Map.put(acc, key, val) end)

    meta_f =
      %{
        when: "#{date_f}T#{time_f}",
        what: "#{what}",
        severity: "#{level}",
        text: "#{message}",
        at: "#{module}.#{function}:#{line}",
        pid: "#{inspect(pid)}"
      }
      |> Map.merge(custom_metadata)
      |> Jason.encode!()

    "#{meta_f}\n"
  rescue
    reason -> "unable to format (#{inspect(reason)}): #{inspect({level, message, metadata})}\n"
  end
end
