defmodule MongoosePushWeb.Support.RequestsGenerator do
  # APIv2/3 requests
  def mandatory_fields() do
    StreamData.fixed_map(%{
      "alert" =>
        StreamData.fixed_map(%{
          "title" => nonempty_string(),
          "body" => nonempty_string()
        }),
      "service" => service()
    })
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
      "data" => data(),
      "mode" => mode(),
      "priority" => priority(),
      "mutable_content" => boolean(),
      "tags" => tags(),
      "topic" => nonempty_string(),
      "time_to_live" => positive_integer()
    })
  end

  def device_id() do
    nonempty_string()
  end

  def mandatory_field() do
    one_of_strings([:service, :title, :body])
  end

  # basic types
  defp nonempty_string() do
    StreamData.string(:alphanumeric, min_length: 1)
  end

  defp positive_integer() do
    StreamData.positive_integer()
  end

  defp boolean() do
    StreamData.one_of([false, true])
  end

  defp tags() do
    StreamData.list_of(nonempty_string(), min_length: 1, max_length: 5)
  end

  defp priority() do
    one_of_strings([:normal, :high])
  end

  defp service() do
    one_of_strings([:apns, :fcm])
  end

  defp mode() do
    one_of_strings([:prod, :dev])
  end

  defp data() do
    StreamData.map_of(StreamData.string(:ascii), StreamData.string(:ascii))
  end

  defp one_of_strings(list_of_atoms) do
    StreamData.map(StreamData.one_of(list_of_atoms), &Kernel.to_string/1)
  end
end
