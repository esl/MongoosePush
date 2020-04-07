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

    case sparrow_config do
      {:error, reason} ->
        {:stop, reason}

      _ ->
        children = [
          Supervisor.child_spec({Sparrow.APNS.Supervisor, sparrow_config},
            id: :apns_pool_supervisor
          ),
          {MongoosePush.Service.APNS.State, pool_configs}
        ]

        :telemetry.execute(
          [:mongoose_push, :apns, :supervisor, :init],
          %{},
          %{}
        )

        Supervisor.init(children, strategy: :one_for_one)
    end
  end

  defp create_sparrow_config(pool_configs) do
    {dev_cert_pools, dev_cert_errors} =
      pool_configs
      |> Enum.filter(fn {_, pool_config} ->
        pool_config[:mode] == :dev and
          pool_config[:auth][:type] == :certificate
      end)
      |> List.foldl({[], []}, &convert_cert_pool_to_sparrow/2)

    {prod_cert_pools, prod_cert_errors} =
      pool_configs
      |> Enum.filter(fn {_, pool_config} ->
        pool_config[:mode] == :prod and
          pool_config[:auth][:type] == :certificate
      end)
      |> List.foldl({[], []}, &convert_cert_pool_to_sparrow/2)

    {dev_token_pools, dev_tokens, dev_token_errors} =
      pool_configs
      |> Enum.filter(fn {_, pool_config} ->
        pool_config[:mode] == :dev and
          pool_config[:auth][:type] == :token
      end)
      |> List.foldl({[], [], []}, &convert_token_pool_to_sparrow/2)

    {prod_token_pools, prod_tokens, prod_token_errors} =
      pool_configs
      |> Enum.filter(fn {_, pool_config} ->
        pool_config[:mode] == :prod and
          pool_config[:auth][:type] == :token
      end)
      |> List.foldl({[], [], []}, &convert_token_pool_to_sparrow/2)

    all_errors = dev_cert_errors ++ prod_cert_errors ++ dev_token_errors ++ prod_token_errors
    error = Enum.find(all_errors, nil, fn err -> !is_nil(err) end)

    if is_nil(error) do
      [
        {:dev, dev_cert_pools ++ dev_token_pools},
        {:prod, prod_cert_pools ++ prod_token_pools},
        {:tokens, dev_tokens ++ prod_tokens}
      ]
    else
      {:error, error}
    end
  end

  defp convert_cert_pool_to_sparrow({pool_name, pool_config}, {mode_list, errors}) do
    pool_size = pool_config[:pool_size]
    endpoint_mode = @default_endpoints[pool_config[:mode]]
    port = if pool_config[:use_2197], do: 2197, else: nil

    cert_path = pool_config[:auth][:cert]
    key_path = pool_config[:auth][:key]

    error =
      case not File.exists?(cert_path) or not File.exists?(key_path) do
        true ->
          Logger.error("Unable to find required files",
            what: :configuration,
            result: :error,
            reason: :bad_auth,
            mode: pool_config[:mode],
            cert_path: cert_path,
            key_path: key_path
          )

          :bad_auth

        false ->
          nil
      end

    single_config =
      [
        auth_type: :certificate_based,
        cert: cert_path,
        key: key_path,
        worker_num: pool_size,
        endpoint: pool_config[:endpoint] || endpoint_mode,
        port: port,
        pool_name: pool_name,
        tags: pool_config[:tags],
        tls_opts: pool_config[:tls_opts]
      ]
      |> Enum.filter(fn {_key, value} -> !is_nil(value) end)

    {[single_config | mode_list], [error | errors]}
  end

  defp convert_token_pool_to_sparrow({pool_name, pool_config}, {mode_list, tokens, errors}) do
    pool_size = pool_config[:pool_size]
    endpoint_mode = @default_endpoints[pool_config[:mode]]
    port = if pool_config[:use_2197], do: 2197, else: nil

    key = pool_config[:auth][:key_id]
    team = pool_config[:auth][:team_id]
    p8_file_path = pool_config[:auth][:p8_file_path]
    token_id = String.to_atom("Token.#{Atom.to_string(pool_config[:id])}")

    error =
      case is_nil(key) or is_nil(team) or not File.exists?(p8_file_path) do
        true ->
          Logger.error("Required configuration missing",
            what: :configuration,
            result: :error,
            reason: :bad_auth,
            mode: pool_config[:mode],
            key: key,
            team: team,
            p8_file: p8_file_path
          )

          :bad_auth

        false ->
          nil
      end

    single_config =
      [
        auth_type: :token_based,
        worker_num: pool_size,
        endpoint: pool_config[:endpoint] || endpoint_mode,
        port: port,
        pool_name: pool_name,
        token_id: token_id,
        tags: pool_config[:tags],
        tls_opts: pool_config[:tls_opts]
      ]
      |> Enum.filter(fn {_key, value} -> !is_nil(value) end)

    token = [
      token_id: token_id,
      key_id: key,
      team_id: team,
      p8_file_path: p8_file_path
    ]

    {[single_config | mode_list], [token | tokens], [error | errors]}
  end
end
