defmodule MongoosePushWeb.HealthcheckController do
  use MongoosePushWeb, :controller

  def send(conn = %Plug.Conn{}, %{}) do
    connections =
      Enum.map(Sparrow.Pool.stats(), &extract_connection_info_from_pool/1)

    status = get_status(connections)

    payload = format_response(connections)

    conn
    |> put_status(status)
    |> json(payload)
  end

  defp extract_connection_info_from_pool(pool) do
    %{
      pool_name: pool.pool,
      connection_status: %{
        connected: pool.connected,
        disconnected: pool.connections - pool.connected
      }
    }
  end

  defp get_status(connections) do
    is_everything_disconnected = Enum.all?(connections, &is_pool_disconnected?/1)

    case is_everything_disconnected do
      true ->
        503

      false ->
        200
    end
  end

  defp is_pool_disconnected?(pool_info) do
    pool_info[:connection_status][:connected] == 0
  end

  # Response formatted to match the draft RFC for healthcheck endpoints, described here:
  # https://datatracker.ietf.org/doc/draft-inadarei-api-health-check
  defp format_response(connections) do
    {_, pool_infos} = Enum.map_reduce(connections, %{}, &format_pool_info/2)

    statuses =
      pool_infos
      |> Map.values()
      |> List.flatten()
      |> Enum.map(fn pool_info ->
        Map.fetch!(pool_info, :status)
      end)

    health =
      cond do
        Enum.all?(statuses, fn st -> st == "pass" end) ->
          "pass"

        Enum.all?(statuses, fn st -> st == "fail" end) ->
          "fail"

        true ->
          "warn"
      end

    %{
      status: health,
      version: List.to_string(Application.spec(:mongoose_push, :vsn)),
      description: "Health of MongoosePush connections to FCM and APNS services",
      checks: pool_infos
    }
  end

  defp format_pool_info(pool_info, acc) do
    status =
      case is_pool_disconnected?(pool_info) do
        true ->
          "fail"

        false ->
          "pass"
      end

    pool_name = "pool:#{pool_info[:pool_name]}"

    pool_details = [
      %{
        status: status,
        time: DateTime.utc_now(),
        output: pool_info[:connection_status]
      }
    ]

    new_acc = Map.put(acc, pool_name, pool_details)

    {pool_info, new_acc}
  end
end
