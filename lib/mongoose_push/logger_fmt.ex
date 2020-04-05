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

    custom_metadata = Keyword.drop(metadata, [:module, :function, :line, :pid, :mfa, :time, :gl])

    meta_f =
      [
        when: "#{date_f}T#{time_f}",
        severity: level,
        what: message,
        at: "#{module}.#{function}:#{line}",
        pid: pid
      ]
      |> Keyword.merge(custom_metadata)
      |> flatten_metadata()
      |> Logfmt.encode()

    "#{meta_f}\n"
  rescue
    reason -> "unable to format (#{inspect(reason)}): #{inspect({level, message, metadata})}"
  end

  defp flatten_metadata(metadata) do
    Enum.flat_map(metadata, &flatten_metadata_elem/1)
  end

  defp flatten_metadata_elem({key, value}) when is_map(value) do
    Enum.flat_map(value, fn {sub_key, sub_value} ->
      flatten_metadata_elem({"#{key}.#{sub_key}", sub_value})
    end)
  end

  defp flatten_metadata_elem({key, value}) when is_tuple(value) do
    flatten_metadata_elem({key, Tuple.to_list(value)})
  end

  defp flatten_metadata_elem({key, value}) when is_list(value) do
    if Keyword.keyword?(value) do
      flatten_metadata_elem({key, Map.new(value)})
    else
      value
      |> Enum.with_index()
      |> Enum.flat_map(fn {elem, idx} ->
        flatten_metadata_elem({"#{key}[#{idx}]", elem})
      end)
    end
  end

  defp flatten_metadata_elem({key, value}), do: [{key, value}]
end
