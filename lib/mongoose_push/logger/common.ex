defmodule MongoosePush.Logger.Common do
  @moduledoc """
  Common logs formatters' helper functions
  """
  def flatten_metadata(metadata) do
    Enum.flat_map(metadata, &flatten_metadata_elem/1)
  end

  defp flatten_metadata_elem({key, %_{} = value}) do
    flatten_metadata_elem({key, Map.from_struct(value)})
  end

  defp flatten_metadata_elem({key, value}) when is_map(value) do
    Enum.flat_map(value, fn {sub_key, sub_value} ->
      flatten_metadata_elem({"#{key}.#{sub_key}", sub_value})
    end)
  end

  defp flatten_metadata_elem({key, value}) when is_tuple(value) do
    flatten_metadata_elem({key, Tuple.to_list(value)})
  end

  defp flatten_metadata_elem({key, value}) when is_function(value) do
    flatten_metadata_elem({key, "#{inspect(value)}"})
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
