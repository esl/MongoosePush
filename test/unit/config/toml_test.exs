defmodule MongoosePush.TomlTest do
  use ExUnit.Case

  alias MongoosePush.Config.Provider.Toml, as: Provider

  test "toml overries log level" do
    for level <- [:debug, :info, :warn, :error] do
      sysconfig =
        Provider.update_sysconfig(
          default_sysconfig(),
          Toml.decode!(
            """
            [general.logging]
            level = "#{level}"
            """,
            keys: :atoms
          )
        )

      assert sysconfig[:logging][:level] == level
    end
  end

  test "toml overries all endpoint settings" do
    sysconfig =
      Provider.update_sysconfig(
        default_sysconfig(),
        Toml.decode!(
          """
          [general.https]
          bind = { addr = "1.2.3.4", port = 4321 }
          num_acceptors = 5738
          certfile = "/cert.pem"
          keyfile = "/key.pem"
          cacertfile = "/ca.pem"
          """,
          keys: :atoms
        )
      )

    assert sysconfig[MongoosePushWeb.Endpoint][:https][:ip] == {1, 2, 3, 4}
    assert sysconfig[MongoosePushWeb.Endpoint][:https][:port] == 4321
    assert sysconfig[MongoosePushWeb.Endpoint][:https][:keyfile] == "/key.pem"
    assert sysconfig[MongoosePushWeb.Endpoint][:https][:certfile] == "/cert.pem"
    assert sysconfig[MongoosePushWeb.Endpoint][:https][:cacertfile] == "/ca.pem"
    assert sysconfig[MongoosePushWeb.Endpoint][:https][:transport_options][:num_acceptors] == 5738

    assert sysconfig[MongoosePushWeb.Endpoint][:server] == true
  end

  test "toml overries openapi settings" do
    sysconfig =
      Provider.update_sysconfig(
        default_sysconfig(),
        Toml.decode!(
          """
          [general.openapi]
          expose_spec = true
          expose_ui = true
          """,
          keys: :atoms
        )
      )

    assert sysconfig[:openapi][:expose_spec] == true
    assert sysconfig[:openapi][:expose_ui] == true
  end

  test "toml overries some endpoint settings" do
    sysconfig =
      Provider.update_sysconfig(
        default_sysconfig(),
        Toml.decode!(
          """
          [general.https]
          bind = { port = 4321 }
          certfile = "/cert.pem"
          cacertfile = "/ca.pem"
          """,
          keys: :atoms
        )
      )

    assert sysconfig[MongoosePushWeb.Endpoint][:https][:ip] == {127, 0, 0, 1}
    assert sysconfig[MongoosePushWeb.Endpoint][:https][:port] == 4321
    assert sysconfig[MongoosePushWeb.Endpoint][:https][:keyfile] == "priv/ssl/fake_key.pem"
    assert sysconfig[MongoosePushWeb.Endpoint][:https][:certfile] == "/cert.pem"
    assert sysconfig[MongoosePushWeb.Endpoint][:https][:cacertfile] == "/ca.pem"
    assert sysconfig[MongoosePushWeb.Endpoint][:https][:transport_options][:num_acceptors] == 100

    assert sysconfig[MongoosePushWeb.Endpoint][:server] == true
  end

  test "toml disables all services by default" do
    sysconfig =
      Provider.update_sysconfig(
        default_sysconfig(),
        Toml.decode!(
          """
          """,
          keys: :atoms
        )
      )

    assert sysconfig[:fcm_enabled] == false
    assert sysconfig[:fcm] == []
    assert sysconfig[:apns_enabled] == false
    assert sysconfig[:apns] == []
  end

  test "toml defines fcm pool" do
    sysconfig =
      Provider.update_sysconfig(
        default_sysconfig(),
        Toml.decode!(
          """
          [[service.fcm]]
          tags = ["tag1", "tag2"]
          [service.fcm.connection]
            endpoint = "localhost"
            port = 321
            count = 14
          [service.fcm.auth]
            appfile = "priv/fcm/token1.json"

          [[service.fcm]]
          [service.fcm.connection]
            port = 123
            count = 7
          [service.fcm.auth]
            appfile = "priv/fcm/token2.json"
          """,
          keys: :atoms
        )
      )

    assert sysconfig[:apns_enabled] == false
    assert sysconfig[:apns] == []

    assert sysconfig[:fcm_enabled] == true
    assert sysconfig[:fcm][:fcm_1][:endpoint] == "localhost"
    assert sysconfig[:fcm][:fcm_1][:port] == 321
    assert sysconfig[:fcm][:fcm_1][:appfile] == "priv/fcm/token1.json"
    assert sysconfig[:fcm][:fcm_1][:pool_size] == 14
    assert sysconfig[:fcm][:fcm_1][:tags] == ["tag1", "tag2"]
    assert sysconfig[:fcm][:fcm_1][:mode] == :prod

    assert sysconfig[:fcm][:fcm_2][:endpoint] == nil
    assert sysconfig[:fcm][:fcm_2][:port] == 123
    assert sysconfig[:fcm][:fcm_2][:appfile] == "priv/fcm/token2.json"
    assert sysconfig[:fcm][:fcm_2][:pool_size] == 7
    assert sysconfig[:fcm][:fcm_2][:tags] == nil
    assert sysconfig[:fcm][:fcm_2][:mode] == :prod
  end

  test "toml defines apns pool" do
    sysconfig =
      Provider.update_sysconfig(
        default_sysconfig(),
        Toml.decode!(
          """
          [[service.apns]]
            mode = "dev"
            default_topic = "some.topic"
            tags = ["dev", "token"]
            [service.apns.connection]
              use_2197 = false
              count = 123
            [service.apns.auth.token]
              key_id = "some id 1"
              team_id = "my team 1"
              tokenfile = "priv/apns/token_1.p8"


          [[service.apns]]
            mode = "prod"
            default_topic = "some.topic"
            tags = ["prod", "cert"]
            [service.apns.connection]
              endpoint = "localhost"
              count = 78
            [service.apns.auth.certificate]
              keyfile = "priv/apns/key_2.pem"
              certfile = "priv/apns/cert_2.pem"

          [[service.apns]]
            mode = "prod"
            tags = ["prod", "token"]

            [service.apns.connection]
              use_2197 = true
              count = 543

            [service.apns.auth.token]
              key_id = "some id 3"
              team_id = "my team 3"
              tokenfile = "priv/apns/token_3.p8"
          """,
          keys: :atoms
        )
      )

    assert sysconfig[:fcm_enabled] == false
    assert sysconfig[:fcm] == []

    assert sysconfig[:apns_enabled] == true

    assert sysconfig[:apns][:apns_1][:endpoint] == nil
    assert sysconfig[:apns][:apns_1][:use_2197] == false
    assert sysconfig[:apns][:apns_1][:pool_size] == 123
    assert sysconfig[:apns][:apns_1][:tags] == ["dev", "token"]
    assert sysconfig[:apns][:apns_1][:mode] == :dev
    assert sysconfig[:apns][:apns_1][:default_topic] == "some.topic"
    assert sysconfig[:apns][:apns_1][:auth][:type] == :token
    assert sysconfig[:apns][:apns_1][:auth][:key] == nil
    assert sysconfig[:apns][:apns_1][:auth][:cert] == nil
    assert sysconfig[:apns][:apns_1][:auth][:key_id] == "some id 1"
    assert sysconfig[:apns][:apns_1][:auth][:team_id] == "my team 1"
    assert sysconfig[:apns][:apns_1][:auth][:p8_file_path] == "priv/apns/token_1.p8"

    assert sysconfig[:apns][:apns_2][:endpoint] == "localhost"
    assert sysconfig[:apns][:apns_2][:use_2197] == false
    assert sysconfig[:apns][:apns_2][:pool_size] == 78
    assert sysconfig[:apns][:apns_2][:tags] == ["prod", "cert"]
    assert sysconfig[:apns][:apns_2][:mode] == :prod
    assert sysconfig[:apns][:apns_2][:default_topic] == "some.topic"
    assert sysconfig[:apns][:apns_2][:auth][:type] == :certificate
    assert sysconfig[:apns][:apns_2][:auth][:key] == "priv/apns/key_2.pem"
    assert sysconfig[:apns][:apns_2][:auth][:cert] == "priv/apns/cert_2.pem"
    assert sysconfig[:apns][:apns_2][:auth][:key_id] == nil
    assert sysconfig[:apns][:apns_2][:auth][:team_id] == nil
    assert sysconfig[:apns][:apns_2][:auth][:p8_file_path] == nil

    assert sysconfig[:apns][:apns_3][:endpoint] == nil
    assert sysconfig[:apns][:apns_3][:use_2197] == true
    assert sysconfig[:apns][:apns_3][:pool_size] == 543
    assert sysconfig[:apns][:apns_3][:tags] == ["prod", "token"]
    assert sysconfig[:apns][:apns_3][:mode] == :prod
    assert sysconfig[:apns][:apns_3][:default_topic] == nil
    assert sysconfig[:apns][:apns_3][:auth][:type] == :token
    assert sysconfig[:apns][:apns_3][:auth][:key_id] == "some id 3"
    assert sysconfig[:apns][:apns_3][:auth][:team_id] == "my team 3"
    assert sysconfig[:apns][:apns_3][:auth][:p8_file_path] == "priv/apns/token_3.p8"
  end

  test "toml config crashes with invalid log level" do
    invalid_toml =
      Toml.decode!(
        """
        [general.logging]
        level = "something"
        """,
        keys: :atoms
      )

    assert_raise RuntimeError, ~r"Invalid loglevel", fn ->
      Provider.update_sysconfig(default_sysconfig(), invalid_toml)
    end
  end

  test "toml config crashes with invalid bind ip" do
    invalid_toml =
      Toml.decode!(
        """
        [general.https]
          bind = { addr = "this is not IP" }
        """,
        keys: :atoms
      )

    assert_raise RuntimeError, ~r"Unable to parse HTTPS bind address", fn ->
      Provider.update_sysconfig(default_sysconfig(), invalid_toml)
    end
  end

  test "toml config crashes with no APNS auth" do
    invalid_toml =
      Toml.decode!(
        """
        [[service.apns]]
            mode = "dev"
            default_topic = "some.topic"
            tags = ["dev", "token"]
        """,
        keys: :atoms
      )

    assert_raise RuntimeError, ~r"No auth method provided for APNS pool", fn ->
      Provider.update_sysconfig(default_sysconfig(), invalid_toml)
    end
  end

  defp default_sysconfig() do
    [
      {:fcm,
       [
         default: [
           endpoint: nil,
           port: nil,
           appfile: "priv/fcm/token.json",
           pool_size: 5,
           mode: :prod
         ]
       ]},
      {:backend_module, MongoosePush},
      {:openapi, [expose_spec: false, expose_ui: false]},
      {:tls_server_cert_validation, false},
      {MongoosePushWeb.Endpoint,
       [
         https: [
           ip: {127, 0, 0, 1},
           port: 8443,
           keyfile: "priv/ssl/fake_key.pem",
           certfile: "priv/ssl/fake_cert.pem",
           cacertfile: "priv/ssl/fake_cert.pem",
           protocol_options: [],
           transport_options: [num_acceptors: 100],
           otp_app: :mongoose_push
         ],
         debug_errors: false,
         code_reloader: false,
         check_origin: true,
         server: true
       ]},
      {:logging, [level: :info]},
      {:fcm_enabled, true},
      {:apns,
       [
         dev: [
           auth: %{
             cert: "priv/apns/dev_cert.pem",
             key: "priv/apns/dev_key.pem",
             key_id: nil,
             p8_file_path: "priv/apns/token.p8",
             team_id: nil,
             type: :token
           },
           endpoint: nil,
           mode: :dev,
           use_2197: false,
           pool_size: 5,
           default_topic: nil
         ],
         prod: [
           auth: %{
             cert: "priv/apns/prod_cert.pem",
             key: "priv/apns/prod_key.pem",
             key_id: nil,
             p8_file_path: "priv/apns/token.p8",
             team_id: nil,
             type: :token
           },
           endpoint: nil,
           mode: :prod,
           use_2197: false,
           pool_size: 5,
           default_topic: nil
         ]
       ]},
      {MongoosePush.Service, [fcm: MongoosePush.Service.FCM, apns: MongoosePush.Service.APNS]},
      {:apns_enabled, false}
    ]
  end
end
