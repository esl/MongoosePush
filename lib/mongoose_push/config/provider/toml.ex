defmodule MongoosePush.Config.Provider.Toml do
  @moduledoc false
  alias MongoosePush.Config.Utils

  @behaviour Config.Provider
  @app :mongoose_push

  @impl true
  def init(opts), do: opts

  @impl true
  def load(config, opts) do
    with true <- is_binary(opts[:path]),
         true <- File.exists?(opts[:path]),
         {:ok, raw_config} <- File.read(opts[:path]),
         {:ok, toml_config} = Toml.decode(raw_config, keys: :atoms) do
      current_sysconfig = Application.get_all_env(@app)
      updated_sysconfig = update_sysconfig(current_sysconfig, toml_config)

      Config.Reader.merge(
        config,
        [
          {@app,
           Keyword.put(updated_sysconfig, :toml_configuration,
             status: {:ok, :loaded},
             path: opts[:path]
           )}
        ]
      )
    else
      {:error, reason} ->
        exit({:error, reason})

      false ->
        Config.Reader.merge(
          config,
          [{@app, [toml_configuration: [status: {:ok, :skipped}, path: :path]]}]
        )
    end
  end

  def update_sysconfig(current_sysconfig, toml_config) do
    current_sysconfig
    |> update_logging_level(toml_config)
    |> update_logging_format(toml_config)
    |> update_endpoint(toml_config)
    |> update_openapi(toml_config)
    |> update_service(toml_config, :fcm)
    |> update_service(toml_config, :apns)
  end

  defp update_logging_level(sysconfig, toml) do
    level =
      case toml[:general][:logging][:level] do
        "debug" -> :debug
        "info" -> :info
        "warn" -> :warn
        "error" -> :error
        nil -> sysconfig[:logging][:level]
        invalid -> raise "Invalid loglevel: #{invalid}!"
      end

    logging = sysconfig[:logging]
    Keyword.put(sysconfig, :logging, Keyword.put(logging, :level, level))
  end

  defp update_logging_format(sysconfig, toml) do
    format =
      case toml[:general][:logging][:format] do
        "logfmt" -> :logfmt
        "json" -> :json
        nil -> sysconfig[:logging][:format]
        invalid -> raise "Invalid logformat: #{invalid}!"
      end

    logging = sysconfig[:logging]
    Keyword.put(sysconfig, :logging, Keyword.put(logging, :format, format))
  end

  defp update_endpoint(sysconfig, toml) do
    https_toml = toml[:general][:https]
    current = Keyword.get(sysconfig, MongoosePushWeb.Endpoint, [])
    addr = https_toml[:bind][:addr]

    bind_addr =
      case parse_bind_addr(addr) do
        {:ok, ip} ->
          ip

        {:error, reason} ->
          raise "Unable to parse HTTPS bind address: #{reason}!"
      end

    https = [
      ip: bind_addr || current[:https][:ip],
      port: https_toml[:bind][:port] || current[:https][:port],
      keyfile: https_toml[:keyfile] || current[:https][:keyfile],
      certfile: https_toml[:certfile] || current[:https][:certfile],
      cacertfile: https_toml[:cacertfile] || current[:https][:cacertfile],
      transport_options: [
        num_acceptors:
          https_toml[:num_acceptors] || current[:https][:transport_options][:num_acceptors]
      ],
      otp_app: :mongoose_push
    ]

    updated_endpoint = Keyword.put(current, :https, https)
    Keyword.put(sysconfig, MongoosePushWeb.Endpoint, updated_endpoint)
  end

  defp update_openapi(sysconfig, toml) do
    openapi_toml = toml[:general][:openapi]

    updated_openapi = [
      expose_spec: openapi_toml[:expose_spec] || sysconfig[:openapi][:expose_spec],
      expose_ui: openapi_toml[:expose_ui] || sysconfig[:openapi][:expose_spec]
    ]

    Keyword.put(sysconfig, :openapi, updated_openapi)
  end

  defp update_service(sysconfig, toml, service) do
    service_enumerated = Enum.with_index(toml[:service][service] || [], 1)

    parsed_service =
      service_enumerated
      |> Enum.map(fn {data, i} ->
        parsed_data = parse_service(service, data)
        {String.to_atom("#{service}_#{i}"), parsed_data}
      end)

    sysconfig
    |> Keyword.put(service, parsed_service)
    |> Keyword.put(String.to_atom("#{service}_enabled"), length(parsed_service) > 0)
  end

  defp parse_service(:fcm, toml) do
    [
      endpoint: toml[:connection][:endpoint],
      port: toml[:connection][:port],
      appfile: toml[:auth][:appfile],
      pool_size: toml[:connection][:count] || 5,
      tags: toml[:tags],
      mode: :prod
    ]
  end

  defp parse_service(:apns, toml) do
    auth_config =
      cond do
        toml[:auth][:token] ->
          %{
            type: :token,
            key_id: toml[:auth][:token][:key_id],
            team_id: toml[:auth][:token][:team_id],
            p8_file_path: toml[:auth][:token][:tokenfile]
          }

        toml[:auth][:certificate] ->
          %{
            type: :certificate,
            cert: toml[:auth][:certificate][:certfile],
            key: toml[:auth][:certificate][:keyfile]
          }

        true ->
          raise "No auth method provided for APNS pool"
      end

    [
      auth: auth_config,
      endpoint: toml[:connection][:endpoint],
      mode: String.to_atom(toml[:mode]),
      use_2197: toml[:connection][:use_2197] || false,
      pool_size: toml[:connection][:count] || 5,
      default_topic: toml[:default_topic],
      tags: toml[:tags]
    ]
  end

  defp parse_bind_addr(nil), do: {:ok, nil}
  defp parse_bind_addr(addr), do: Utils.parse_bind_addr(addr)
end
