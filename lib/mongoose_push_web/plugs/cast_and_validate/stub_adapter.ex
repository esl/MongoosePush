defmodule MongoosePushWeb.Plug.CastAndValidate.StubAdapter do
  @moduledoc """
  Module which is an almost empty Plug.Conn.Adapter behavior implementation.
  It is used by MongoosePushWeb.Plug.CastAndValidate plug
  as the part of the workaround this module introduces.
  """
  @behaviour Plug.Conn.Adapter

  @impl true
  def chunk(_conn, _chunk) do
    :ok
  end

  @impl true
  def get_http_protocol(_payload) do
    :"HTTP/2"
  end

  @impl true
  def get_peer_data(_payload) do
    %{address: {127, 0, 0, 1}, port: 111_317, ssl_cert: nil}
  end

  @impl true
  def inform(_payload, _arg2, _headers) do
    {:error, :not_supported}
  end

  @impl true
  def push(_payload, _path, _headers) do
    {:error, :not_supported}
  end

  @impl true
  def read_req_body(_payload, _options) do
    {:error, :not_supported}
  end

  @impl true
  def send_chunked(req, _status, _headers) do
    {:ok, nil, req}
  end

  @impl true
  def send_file(payload, _status, _headers, _file, _offset, _length) do
    {:ok, nil, payload}
  end

  @impl true
  def send_resp(payload, _status, _headers, _body) do
    {:ok, nil, payload}
  end
end
