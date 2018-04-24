defmodule RestH2Test do
  use ExUnit.Case
  import Mock

  @url "/v2/notification/f534534543"

  # Since protocol is the only thing that changes, there's no point in testing the whole API
  test "correct params return 200 over HTTP/2" do
    with_mock MongoosePush, [push: fn(_, _) -> :ok end] do

      {:ok, conn} = get_connection()

      assert 200 = post(conn, @url, %{service: :apns,  alert: %{body: "body", title: "title"}})
      assert 200 = post(conn, @url, %{service: :fcm,   alert: %{body: "body", title: "title"}})

      assert 200 = post(conn, @url, %{service: :apns,  data: %{a1: "test", a2: "test"}})
      assert 200 = post(conn, @url, %{service: :fcm,   data: %{a1: "test", a2: "test"}})
    end
  end

  defp get_connection() do
    :h2_client.start_link(:https, 'localhost', 8443, [])
  end

  defp post(conn, path, json) do
    headers = headers("POST", path)
    :h2_client.send_request(conn, headers, Poison.encode!(json))
    get_response(conn)
  end

  defp get_response(conn) do
    receive do
      {:END_STREAM, stream_id} ->
        {:ok, {headers, _body}} = :h2_client.get_response(conn, stream_id)
        List.keyfind(headers, ":status", 0)
        |> Kernel.elem(1)
        |> String.to_integer()
    end
  end

  defp headers(method, path, payload \\ "") do
    [
      {":method", method},
      {":authority", "localhost"},
      {":scheme", "https"},
      {":path", path},
      {"content-length", "#{byte_size(payload)}"},
      {"content-type", "application/json"}
    ]
  end

end
