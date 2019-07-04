defmodule MongoosePush.Service.APNS.Supervisor do
  @moduledoc """
  APNS module supervising Sparrow's PoolSupervisor and APNS State
  """
  use Supervisor, id: :apns_supervisor
  require Logger
  alias MongoosePush.Application

  @default_endpoints %{
    dev: "api.development.push.apple.com",
    prod: "api.push.apple.com"
  }

  @spec start_link([Application.pool_definition()]) :: Supervisor.on_start()
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  @impl true
  def init(pool_configs) do
    sparrow_config = create_sparrow_config(pool_configs)

    children = [
      Supervisor.child_spec({Sparrow.APNS.Pool.Supervisor, sparrow_config},
        id: :apns_pool_supervisor
      ),
      {MongoosePush.Service.APNS.State, pool_configs}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp create_sparrow_config(pool_configs) do
    dev_pools =
      pool_configs
      |> Enum.filter(fn {_, pool_config} -> pool_config[:mode] == :dev end)
      |> List.foldl([], &convert_pool_to_sparrow/2)

    prod_pools =
      pool_configs
      |> Enum.filter(fn {_, pool_config} -> pool_config[:mode] == :prod end)
      |> List.foldl([], &convert_pool_to_sparrow/2)

    [{:dev, dev_pools}, {:prod, prod_pools}]
  end

  defp convert_pool_to_sparrow({pool_name, pool_config}, mode_list) do
    auth_type = {:auth_type, :certificate_based}
    cert = {:cert, pool_config[:cert]}
    key = {:key, pool_config[:key]}
    pool_size = {:worker_num, pool_config[:pool_size]}

    endpoint_mode = @default_endpoints[pool_config[:mode]]
    endpoint = {:endpoint, pool_config[:endpoint] || endpoint_mode}

    port_config =
      case pool_config[:use_2197] do
        true ->
          2197

        _ ->
          nil
      end

    port = {:port, port_config}

    name = {:pool_name, pool_name}

    single_config =
      [auth_type, cert, key, pool_size, endpoint, port, name]
      |> Enum.filter(fn {_key, value} -> !is_nil(value) end)

    [single_config | mode_list]
  end
end
