defmodule RequestsGenerator do
  # basic types
  def nonempty_string() do
    StreamData.string(:alphanumeric) |> StreamData.filter(fn x -> String.length(x) > 0 end)
  end

  def positive_integer() do
    StreamData.positive_integer()
  end

  def boolean() do
    StreamData.one_of([false, true])
  end

  def tags_type() do
    StreamData.list_of(nonempty_string(), min_length: 1, max_length: 5)
  end

  def priority_type() do
    one_of_strings([:normal, :high])
  end

  def service_type() do
    one_of_strings([:apns, :fcm])
  end

  def mode_type() do
    one_of_strings([:prod, :dev])
  end

  def data_type() do
    StreamData.map_of(StreamData.string(:ascii), StreamData.string(:ascii))
  end

  # requests creation
  def mandatory_fields() do
    StreamData.fixed_map(%{
      "alert" =>
        StreamData.fixed_map(%{
          "title" => nonempty_string(),
          "body" => nonempty_string()
        }),
      "service" => one_of_strings([:apns, :fcm])
    })
  end

  def mandatory_field() do
    one_of_strings([:service, :title, :body])
  end

  def optional_fields() do
    StreamData.optional_map(%{
      "alert" =>
        StreamData.optional_map(%{
          "badge" => positive_integer(),
          "click_action" => nonempty_string(),
          "tag" => nonempty_string(),
          "sound" => nonempty_string()
        }),
      "data" => data_type(),
      "mode" => mode_type(),
      "priority" => priority_type(),
      "mutable_content" => boolean(),
      "tags" => tags_type(),
      "topic" => nonempty_string(),
      "time_to_live" => positive_integer()
    })
  end

  defp one_of_strings(list) do
    StreamData.map(StreamData.one_of(list), &Kernel.to_string/1)
  end
end
