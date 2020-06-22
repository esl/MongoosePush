defmodule MongoosePushWeb.HealthcheckController do
  use MongoosePushWeb, :controller

  def send(conn = %Plug.Conn{}, %{}) do
    stats = :wpool.stats()

    payload =
      stats
      |> Enum.map(&extract_connection_info_from_pool/1)

    status = get_status(payload)

    conn
    |> put_status(status)
    |> json(payload)
  end

  defp extract_connection_info_from_pool(pool) do
    pool_pid = pool[:supervisor]
    children = Supervisor.which_children(pool_pid)
    {_, sup_pid, _, _} = List.keyfind(children, [:wpool_process_sup], 3)
    workers = Supervisor.which_children(sup_pid)

    connections =
      workers
      |> Enum.map(fn worker_info ->
        {_, worker_pid, _, _} = worker_info

        if Sparrow.H2Worker.is_alive_connection(worker_pid) do
          :connected
        else
          :disconnected
        end
      end)

    %{
      pool: pool[:pool],
      connection_status: connections
    }
  end

  defp get_status(connections) do
    is_everything_disconnected =
      Enum.all?(connections, fn pool_info ->
        Enum.all?(pool_info[:connection_status], fn
          status -> status == :disconnected
        end)
      end)

    case is_everything_disconnected do
      true ->
        503

      false ->
        200
    end
  end
end
