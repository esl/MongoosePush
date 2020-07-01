defmodule MongoosePushWeb.HealthcheckController do
  use MongoosePushWeb, :controller

  def send(conn = %Plug.Conn{}, %{}) do
    stats = :wpool.stats()

    connections =
      stats
      |> Enum.map(&extract_connection_info_from_pool/1)

    status = get_status(connections)

    payload = format_response(status, connections)

    conn
    |> put_status(status)
    |> json(payload)
  end

  defp extract_connection_info_from_pool(pool) do
    pool_pid = pool[:supervisor]
    children = Supervisor.which_children(pool_pid)
    {_, sup_pid, _, _} = List.keyfind(children, [:wpool_process_sup], 3)
    workers = Supervisor.which_children(sup_pid)

    {_workers, connection_status} =
      workers
      |> Enum.map_reduce(%{connected: 0, disconnected: 0}, fn worker_info, acc ->
        {_, worker_pid, _, _} = worker_info

        if Sparrow.H2Worker.is_alive_connection(worker_pid) do
          {worker_info, Map.update!(acc, :connected, &(&1 + 1))}
        else
          {worker_info, Map.update!(acc, :disconnected, &(&1 + 1))}
        end
      end)

    %{
      pool_name: pool[:pool],
      connection_status: connection_status
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
    case pool_info[:connection_status][:connected] do
      0 ->
        true

      _ ->
        false
    end
  end

  # Response formatted to match the draft RFC for healthcheck endpoints, described here:
  # https://tools.ietf.org/id/draft-inadarei-api-health-check-01.html
  defp format_response(status, connections) do
    {_, pool_infos} =
      connections
      |> Enum.map_reduce(%{}, &format_pool_info/2)

    health =
      case status do
        503 ->
          "fail"

        200 ->
          "pass"
      end

    %{
      status: health,
      version: "2",
      releaseID: "2.0.2",
      description: "Health of MongoosePush connections to FCM and APNS services",
      details: pool_infos
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
