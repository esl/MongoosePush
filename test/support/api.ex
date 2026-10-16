defmodule MongoosePush.Support.API do
  alias Req.Response

  @api_url "https://localhost:8443"
  # The connections are closed, so that they do not delay stopping the endpoint
  @api_opts [
    headers: [{"connection", "close"}],
    retry: false,
    decode_body: false,
    connect_options: [transport_opts: [verify: :verify_none]]
  ]

  @mock_client __MODULE__.MockClient
  @mock_urls %{apns: "https://localhost:2197", fcm: "https://localhost:4000"}
  @mock_connect_retries 100

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

  def sample_bad_notification(service) do
    %{
      :service => service,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"
      },
      :data => %{
        :x => %{"a" => 222}
      }
    }
  end

  def get(path) do
    %Response{status: status, headers: headers, body: body} =
      Req.get!(@api_url <> path, @api_opts)

    {status, for({name, values} <- headers, value <- values, do: {name, value}), body}
  end

  def post(path, json) do
    {status_code, body} = post_conn_error(path, json)
    {status_code, Poison.decode!(body)}
  end

  def post_conn_error(path, json) do
    %Response{status: status_code, body: body} =
      Req.post!(
        @api_url <> path,
        Keyword.merge(@api_opts,
          body: Poison.encode!(json),
          headers: [{"content-type", "application/json"} | @api_opts[:headers]]
        )
      )

    {status_code, body}
  end

  def mock_apns(json) do
    {200, _payload} = mock_request(:apns, :post, "/mock/error-tokens", Poison.encode!(json))
    :ok
  end

  def mock_fcm(path, json) do
    Req.post!(
      "http://localhost:4001/mock" <> path,
      body: Poison.encode!(json),
      headers: [{"content-type", "application/json"}],
      retry: false,
      decode_body: false
    )
  end

  def reset(:apns) do
    {200, ""} = mock_request(:apns, :post, "/mock/reset")
    :ok
  end

  def reset(:fcm) do
    %Response{status: 200} = mock_fcm("/reset", "")
  end

  def start_mock_client do
    {:ok, _} = Application.ensure_all_started(:finch)

    {:ok, _} =
      Finch.start_link(
        name: @mock_client,
        pools: %{
          default: [
            protocols: [:http2],
            conn_opts: [transport_opts: [verify: :verify_none]]
          ]
        }
      )

    :ok
  end

  def mock_request(service, method, path, payload \\ "") do
    {:ok, %Finch.Response{status: status, body: body}} =
      method
      |> Finch.build(@mock_urls[service] <> path, [{"content-type", "application/json"}], payload)
      |> request_when_connected(@mock_connect_retries)

    {status, body}
  end

  # A HTTP/2 pool of Finch is not available until its connection is established
  defp request_when_connected(request, retries) do
    case Finch.request(request, @mock_client) do
      {:error, %Finch.Error{reason: :pool_not_available}} when retries > 0 ->
        Process.sleep(50)
        request_when_connected(request, retries - 1)

      result ->
        result
    end
  end
end
