defmodule MongoosePushAPIV2Test do
  require Logger
  use ExUnit.Case, async: false
  use Quixir
  alias HTTPoison.Response
  doctest MongoosePush.API.V2

  @url "/v2/notification/f534534543"

  setup do
    reset(:fcm)
    reset(:apns)
    TestHelper.reload_app()
  end

  test "push to fcm with unknown token fails" do
    args = %{
      :service => :fcm,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"}}


    mock_fcm([%{device_token: "f534534543", status: 404, reason: "UNREGISTERED"}])

    assert {500, "UNREGISTERED"} = post(@url, %{service: :fcm, alert: %{body: "body", title: "title"}})
  end

  defp post(path, json) do
    %Response{status_code: status_code, body: body} =
      HTTPoison.post!(
        "https://localhost:8443" <> path,
        Poison.encode!(json),
        [{"Content-Type", "application/json"}],
        hackney: [:insecure]
      )

    %{"details" => details} = Poison.decode!(body)
    {status_code, details}
  end

  defp mock_fcm(json) do
    {:ok, conn} = get_connection(:fcm)
    payload = Poison.encode!(json)

    headers = headers("POST", "/mock/error-tokens", payload)
    :h2_client.send_request(conn, headers, payload)
    get_response(conn)
    :ok
  end

  defp reset(:apns) do
    {:ok, conn} = get_connection(:apns)
    headers = headers("POST", "/reset")
    :h2_client.send_request(conn, headers, "")
    get_response(conn)
    :ok
  end

  defp reset(:fcm) do
    {:ok, conn} = get_connection(:fcm)
    headers = headers("POST", "/mock/reset")
    :h2_client.send_request(conn, headers, "")
    get_response(conn)
    :ok
  end

  defp get_connection(:apns) do
    :h2_client.start_link(:https, 'localhost', 2197, [])
  end

  defp get_connection(:fcm) do
    :h2_client.start_link(:https, 'localhost', 4000, [])
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

  defp get_response(conn) do
    receive do
      {:END_STREAM, stream_id} ->
        {:ok, {_headers, body}} = :h2_client.get_response(conn, stream_id)
        Enum.join(body)
    end
  end

  defp push(token, notification), do: MongoosePush.push(token, notification)

end



