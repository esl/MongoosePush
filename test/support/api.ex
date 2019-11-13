defmodule MongoosePush.Support.API do
  alias HTTPoison.Response

  def sample_notification(service) do
    %{
      :service => service,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"
      }
    }
  end

  def post(path, json) do
    %Response{status_code: status_code, body: body} =
      HTTPoison.post!(
        "https://localhost:8443" <> path,
        Poison.encode!(json),
        [{"Content-Type", "application/json"}],
        hackney: [:insecure]
      )

    details = Poison.decode!(body)
    {status_code, details}
  end

  def mock_apns(json) do
    {:ok, conn} = get_connection(:apns)
    payload = Poison.encode!(json)

    headers = headers("POST", "/error-tokens", payload)
    :h2_client.send_request(conn, headers, payload)
    {"200", _payload} = get_response(conn)
    :ok
  end

  def mock_fcm(json) do
    {:ok, conn} = get_connection(:fcm)
    payload = Poison.encode!(json)

    headers = headers("POST", "/mock/error-tokens", payload)
    :h2_client.send_request(conn, headers, payload)
    {"200", _payload} = get_response(conn)
  end

  def reset(:apns) do
    {:ok, conn} = get_connection(:apns)
    payload = ""
    headers = headers("POST", "/reset", payload)
    :h2_client.send_request(conn, headers, payload)
    {"200", "OK"} = get_response(conn)
    :ok
  end

  def reset(:fcm) do
    {:ok, conn} = get_connection(:fcm)
    payload = ""
    headers = headers("POST", "/mock/reset", payload)
    :h2_client.send_request(conn, headers, payload)
    {"200", "OK"} = get_response(conn)
    :ok
  end

  def get_connection(:apns) do
    :h2_client.start_link(:https, 'localhost', 2197, [])
  end

  def get_connection(:fcm) do
    :h2_client.start_link(:https, 'localhost', 4000, [])
  end

  def headers(method, path, payload) do
    [
      {":method", method},
      {":authority", "localhost"},
      {":scheme", "https"},
      {":path", path},
      {"content-length", "#{byte_size(payload)}"},
      {"content-type", "application/json"}
    ]
  end

  def get_response(conn) do
    receive do
      {:END_STREAM, stream_id} ->
        {:ok, {headers, body}} = :h2_client.get_response(conn, stream_id)
        {":status", code} = List.keyfind(headers, ":status", 0)
        {code, Enum.join(body)}
    end
  end
end
