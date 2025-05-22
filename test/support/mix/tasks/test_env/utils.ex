defmodule Mix.Tasks.Test.Env.Utils do
  def compose(compose_binary, opcode_args) do
    Mix.shell().info(
      "Running `docker-compose #{Enum.join(opcode_args, " ")}` for: #{inspect(compose_files(Mix.env()))}"
    )

    compose_args = base_compose_args() ++ opcode_args ++ ["--remove-orphans"]

    case System.cmd(compose_binary, compose_args, env: [{"PRIV", "../../priv"}]) do
      {_output, 0} ->
        :ok

      {_output, _} ->
        flunk("Failed to bring up the test environment!")
    end
  end

  def wait_for_services(time_ms) do
    HTTPoison.start()
    wait_for_services("localhost", services(Mix.env()), time_ms)
  end

  def flunk(reason) do
    reason
    |> List.wrap()
    |> Mix.shell().error()

    :erlang.halt(1)
  end

  defp base_compose_args() do
    Mix.env()
    |> compose_files()
    |> Enum.map(fn file ->
      ["-f", "test/docker/#{file}"]
    end)
    |> List.flatten()
  end

  defp wait_for_services(_host, [], _), do: :ok

  defp wait_for_services(host, [srv | rest], time_ms) when time_ms > 0 do
    {proto, port} = srv

    case try_connect(proto, host, port) do
      :ok ->
        wait_for_services(host, rest, time_ms)

      {:error, _reason} ->
        Process.sleep(50)
        wait_for_services(host, [srv | rest], time_ms - 50)
    end
  end

  defp wait_for_services(host, [{proto, port} | _rest], _) do
    flunk("""
    Unable to connect to #{proto}://#{host}:#{port}! Make sure you run `MIX_ENV=#{Mix.env()} mix test.env.up` if you haven't already.
    If you have - you can run the following command to see the docker-compose logs:
    $ docker-compose #{Enum.join(base_compose_args(), " ")} logs
    """)
  end

  defp compose_files(:dev), do: ["docker-compose.mocks.yml"]
  defp compose_files(:test), do: ["docker-compose.mocks.yml"]
  defp compose_files(:integration), do: ["docker-compose.mocks.yml", "docker-compose.mpush.yml"]

  defp compose_files(_env) do
    flunk("The compose environment is only defined for :dev, :test and :integrations MIX_ENVs!")
  end

  defp try_connect(:tcp, host, port) do
    with {:ok, _} <- :gen_tcp.connect(String.to_charlist(host), port, []) do
      :ok
    end
  end

  defp try_connect(proto, host, port) do
    url = "#{proto}://#{host}:#{port}/"

    with {:ok, _} <-
           HTTPoison.get(url, [], ssl: [insecure: true]) do
      :ok
    end
  end

  defp services(:dev), do: services(:test)

  defp services(:test) do
    [
      {:tcp, 2197},
      {:http, 4001},
      {:https, 4000}
    ]
  end

  defp services(:integration) do
    services(:test) ++
      [
        {:https, 8443}
      ]
  end
end
