defmodule MongoosePush.Logger.Fmt do
  @moduledoc """
  Module responsible for FMT-specific logs formatting
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
      Keyword.drop(metadata, [:module, :function, :line, :pid, :mfa, :time, :gl, :what])

    meta_f =
      [
        when: "#{date_f}T#{time_f}",
        severity: level,
        what: what,
        text: "#{message}",
        at: "#{module}.#{function}:#{line}",
        pid: pid
      ]
      |> Keyword.merge(custom_metadata)
      |> flatten_metadata()
      |> Logfmt.encode()

    "#{meta_f}\n"
  rescue
    reason -> "unable to format (#{inspect(reason)}): #{inspect({level, message, metadata})}\n"
  end
end
