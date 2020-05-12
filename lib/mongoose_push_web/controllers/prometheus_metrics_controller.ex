defmodule MongoosePushWeb.PrometheusMetricsController do
  use MongoosePushWeb, :controller

  def send(conn = %Plug.Conn{}, %{}) do
    payload = TelemetryMetricsPrometheus.Core.scrape()
    text(conn, payload)
  end
end
