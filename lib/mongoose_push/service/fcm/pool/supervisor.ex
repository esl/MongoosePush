defmodule MongoosePush.Service.FCM.Pool.Supervisor do
  @moduledoc """
  This module is a basic FCM pool supervisor that has a list of active workers - temporary solution before migrating to Sparrow with its own supervisors
  """
  use Supervisor, id: :fcm_pool_supervisor
  require Logger
  alias MongoosePush.Application

  @default_endpoint "fcm.googleapis.com"
  @default_port 443

  @spec start_link([Application.pool_definition()]) :: Supervisor.on_start()
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  @impl true
  def init(pools_configs) do
    sparrow_config = create_sparrow_config(pools_configs)

    children = [
      Supervisor.child_spec({Sparrow.FCM.V1.Supervisor, sparrow_config},
        id: :fcm_sparrow_supervisor
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp create_sparrow_config(pool_configs) do
    pool_configs
    |> List.foldl([], fn config, acc ->
      [convert_pool_to_sparrow(config) | acc]
    end)
  end

  defp convert_pool_to_sparrow({_pool_name, pool_config}) do
    token_path = {:path_to_json, pool_config[:appfile]}
    endpoint = {:endpoint, pool_config[:endpoint] || @default_endpoint}
    port = {:port, pool_config[:port] || @default_port}
    pool_size = {:worker_num, pool_config[:pool_size]}
    raw_tags = if is_nil(pool_config[:tags]), do: [], else: pool_config[:tags]

    # mode has to be either `prod` or `dev`, for now we pass it in form of a tag
    tags = {:tags, [pool_config[:mode] | raw_tags]}

    [token_path, endpoint, port, pool_size, tags]
    |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
  end
end
