defmodule MongoosePush.LoggerFmt do
  @moduledoc """
  Module responsible for formatting logger output
  """
  def format(level, message, {date, time}, metadata) do
    date_f = Logger.Formatter.format_date(date)
    time_f = Logger.Formatter.format_time(time)

    # Change format of a logging place for readability and compatibility with `:logger` standard
    module = Keyword.fetch!(metadata, :module)
    function = Keyword.fetch!(metadata, :function)
    line = Keyword.fetch!(metadata, :line)
    pid = Keyword.fetch!(metadata, :pid)

    meta_f =
      [what: message]
      |> Keyword.put(:at, "#{module}.#{function}:#{line}")
      |> Keyword.put(:pid, pid)
      |> Logfmt.encode()

    "\n#{date_f} #{time_f} [#{level}] #{meta_f}"
  rescue
    _ -> "unable to format: #{inspect({level, message, metadata})}"
  end
end
