defmodule MongoosePushTest do
  use ExUnit.Case, async: false
  use Quixir

  @test_token "testdeviceid1234"
  @apns_priority_mapping %{normal: "5", high: "10"}
  @dev_topic "dev_topic"
  @prod_topic "prod1_override_topic"

  setup do
    reset(:fcm)
    reset(:apns)
    TestHelper.reload_app()
  end

  describe "apns topic" do
    test "is always set to the value provided with API using :dev mode" do
      assert :ok ==
               push(@test_token, %{
                 :service => :apns,
                 :alert => %{:title => "", :body => ""},
                 mode: :dev,
                 topic: "some_topic"
               })

      apns_request = last_activity(:apns)
      assert @test_token == apns_request["device_token"]
      assert "some_topic" == apns_request["request_headers"]["apns-topic"]
    end

    test "is always set to the value provided with API using :prod mode" do
      assert :ok ==
               push(@test_token, %{
                 :service => :apns,
                 :alert => %{:title => "", :body => ""},
                 mode: :prod,
                 topic: "some_topic"
               })

      apns_request = last_activity(:apns)
      assert @test_token == apns_request["device_token"]
      assert "some_topic" == apns_request["request_headers"]["apns-topic"]
    end
  end

  describe "test apns topic specified in config" do
    setup do
      old_config = Application.fetch_env!(:mongoose_push, :apns)
      new_config = Enum.map(old_config, &add_topic_to_config/1)
      Application.stop(:mongoose_push)
      Application.load(:mongoose_push)
      Application.put_env(:mongoose_push, :apns, new_config)
      Application.start(:mongoose_push)
    end

    test "defaults to value set in config using :dev mode" do
      assert :ok ==
               push(@test_token, %{
                 :service => :apns,
                 :alert => %{:title => "", :body => ""},
                 mode: :dev
               })

      apns_request = last_activity(:apns)
      assert @test_token == apns_request["device_token"]
      assert @dev_topic == apns_request["request_headers"]["apns-topic"]
    end

    test "defaults to value set in config using :prod mode" do
      assert :ok ==
               push(@test_token, %{
                 :service => :apns,
                 :alert => %{:title => "", :body => ""},
                 mode: :prod
               })

      apns_request = last_activity(:apns)
      assert @test_token == apns_request["device_token"]
      assert @prod_topic == apns_request["request_headers"]["apns-topic"]
    end
  end

  describe "test apns topic (without it being specified in pool configs)" do
    setup do
      old_config = Application.fetch_env!(:mongoose_push, :apns)
      new_config = Enum.map(old_config, &delete_topic_from_config/1)
      Application.stop(:mongoose_push)
      Application.load(:mongoose_push)
      Application.put_env(:mongoose_push, :apns, new_config)
      Application.start(:mongoose_push)
    end

    test "defaults to value extracted from cert using :prod mode" do
      assert :ok ==
               push(@test_token, %{
                 :service => :apns,
                 :alert => %{:title => "", :body => ""},
                 mode: :prod
               })

      apns_request = last_activity(:apns)
      assert @test_token == apns_request["device_token"]
      assert "com.inakanetworks.Mangosta" == apns_request["request_headers"]["apns-topic"]
    end

    test "is not set if theres no default value in config nor certificate" do
      assert :ok ==
               push(@test_token, %{
                 :service => :apns,
                 :alert => %{:title => "", :body => ""},
                 mode: :dev
               })

      apns_request = last_activity(:apns)
      assert @test_token == apns_request["device_token"]
      assert nil == apns_request["request_headers"]["apns-topic"]
    end
  end

  test "simple push to apns succeeds" do
    assert :ok ==
             push(
               "device_id",
               %{:service => :apns, :alert => %{:title => "", :body => ""}}
             )
  end

  test "push to apns assign correct message fields" do
    ptest [
            device_token: string(min: 10, max: 15, chars: ?a..?z),
            title: string(min: 3, max: 15, chars: :ascii),
            body: string(min: 10, max: 45, chars: :ascii),
            badge: int(min: 1, max: 20),
            sound: string(min: 3, max: 15, chars: :ascii),
            click_action: string(min: 3, max: 15, chars: :ascii),
            priority: choose(from: [value(:normal), value(:high)]),
            mutable_content: bool()
          ],
          repeat_for: 10 do
      notification = %{
        :service => :apns,
        :priority => priority,
        :mutable_content => mutable_content,
        :alert => %{
          :title => title,
          :body => body,
          :badge => badge,
          :click_action => click_action,
          :sound => sound <> ".wav"
        },
        :data => %{
          "acme1" => "apns1",
          "acme2" => "apns2",
          "acme3" => "apns3"
        }
      }

      assert :ok == push(device_token, notification)

      apns_request = last_activity(:apns)
      aps_data = apns_request["request_data"]["aps"]
      aps_headers = apns_request["request_headers"]
      aps_custom = Map.delete(apns_request["request_data"], "aps")

      assert device_token == apns_request["device_token"]
      assert @apns_priority_mapping[priority] == aps_headers["apns-priority"]

      assert notification.alert[:title] == aps_data["alert"]["title"]
      assert notification.alert[:body] == aps_data["alert"]["body"]
      assert notification.alert[:badge] == aps_data["badge"]
      assert notification.alert[:click_action] == aps_data["category"]
      assert notification.alert[:sound] == aps_data["sound"]
      assert notification[:data] == aps_custom

      if mutable_content do
        assert 1 == aps_data["mutable-content"]
      end
    end
  end

  test "push to fcm assign correct message fields" do
    ptest [
            device_token: string(min: 10, max: 15, chars: ?a..?z),
            title: string(min: 3, max: 15, chars: :ascii),
            body: string(min: 10, max: 45, chars: :ascii),
            tag: string(min: 3, max: 15, chars: :ascii),
            sound: string(min: 3, max: 15, chars: :ascii),
            click_action: string(min: 3, max: 15, chars: :ascii),
            time_to_live: int(min: 0, max: 2_419_200),
            priority: choose(from: [value(:normal), value(:high)])
          ],
          repeat_for: 10 do
      notification = %{
        :service => :fcm,
        :priority => priority,
        :time_to_live => time_to_live,
        :alert => %{
          :title => title,
          :body => body,
          :click_action => click_action,
          :tag => tag,
          :sound => sound <> ".wav"
        },
        :data => %{
          "acme1" => "fcm1",
          "acme2" => "fcm2",
          "acme3" => "fcm3"
        }
      }

      assert :ok == push(device_token, notification)
      fcm_request_data = last_activity(:fcm)["request_data"]
      fcm_message = fcm_request_data["message"]
      fcm_notification = fcm_message["android"]["notification"]
      fcm_data = fcm_message["android"]["data"]

      assert device_token == fcm_message["token"]
      assert Atom.to_string(priority) == String.downcase(fcm_message["android"]["priority"])

      assert notification.alert[:title] == fcm_notification["title"]
      assert notification.alert[:body] == fcm_notification["body"]
      assert notification.alert[:click_action] == fcm_notification["click_action"]
      assert notification.alert[:tag] == fcm_notification["tag"]
      assert notification.alert[:sound] == fcm_notification["sound"]
      assert notification[:data] == fcm_data
      assert notification[:time_to_live] == convert_ttl(fcm_message["android"]["ttl"])
    end
  end

  test "push to fcm assign correct message fields when sending silent notification" do
    notification = %{
      :service => :fcm,
      :data => %{
        "acme1" => "fcm1",
        "acme2" => "fcm2",
        "acme3" => "fcm3"
      }
    }

    assert :ok == push("androidtestdeviceid12", notification)
    fcm_request_data = last_activity(:fcm)["request_data"]
    fcm_message = fcm_request_data["message"]
    fcm_data = fcm_message["android"]["data"]
    fcm_notification = fcm_message["android"]["notification"]

    assert "androidtestdeviceid12" == fcm_message["token"]
    assert nil == fcm_notification["title"]
    assert nil == fcm_notification["body"]
    assert nil == fcm_notification["click_action"]
    assert nil == fcm_notification["tag"]
    assert notification[:data] == fcm_data
  end

  test "push to apns assign correct message fields when sending silent notification" do
    notification = %{
      :service => :apns,
      :data => %{
        "acme1" => "fcm1",
        "acme2" => "fcm2",
        "acme3" => "fcm3"
      }
    }

    assert :ok == push("testdeviceid1234", notification)

    apns_request = last_activity(:apns)
    aps_data = apns_request["request_data"]["aps"]
    aps_custom = Map.delete(apns_request["request_data"], "aps")

    assert "testdeviceid1234" == apns_request["device_token"]
    assert nil == aps_data["alert"]
    assert nil == aps_data["badge"]
    assert nil == aps_data["category"]
    assert 1 == aps_data["content-available"]
    assert notification[:data] == aps_custom
  end

  test "push to fcm with unknown token fails" do
    notification = %{
      :service => :fcm,
      :alert => %{
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"
      }
    }

    fail_tokens(:fcm, [
      %{device_token: "androidtestdeviceid65", status: 404, reason: "UNREGISTERED"}
    ])

    assert {:error, {:unregistered, :UNREGISTERED}} = push("androidtestdeviceid65", notification)
  end

  test "check FCM_ENABLED option" do
    Application.stop(:mongoose_push)
    Application.load(:mongoose_push)
    Application.put_env(:mongoose_push, :fcm_enabled, false)
    Application.start(:mongoose_push)

    apns_entry =
      MongoosePush.Supervisor
      |> Supervisor.which_children()
      |> List.keyfind(:apns_supervisor, 0)

    fcm_entry =
      MongoosePush.Supervisor
      |> Supervisor.which_children()
      |> List.keyfind(:fcm_pool_supervisor, 0)

    assert nil == fcm_entry
    assert nil != apns_entry

    TestHelper.reload_app()
  end

  test "check APNS_ENABLED option" do
    Application.stop(:mongoose_push)
    Application.load(:mongoose_push)
    Application.put_env(:mongoose_push, :apns_enabled, false)
    Application.start(:mongoose_push)

    apns_entry =
      MongoosePush.Supervisor
      |> Supervisor.which_children()
      |> List.keyfind(:apns_supervisor, 0)

    fcm_entry =
      MongoosePush.Supervisor
      |> Supervisor.which_children()
      |> List.keyfind(:fcm_pool_supervisor, 0)

    assert nil != fcm_entry
    assert nil == apns_entry

    TestHelper.reload_app()
  end

  test "APNS token authorization" do
    apns_config = [
      new_dev1: [
        auth: %{
          type: :token,
          key_id: "fake_key",
          team_id: "fake_team",
          p8_file_path: "priv/apns/token.p8"
        },
        endpoint: "localhost",
        mode: :dev,
        use_2197: true,
        pool_size: 3,
        default_topic: "dev_topic1",
        tls_opts: []
      ],
      new_prod1: [
        auth: %{
          type: :token,
          key_id: "fake_key",
          team_id: "fake_team",
          p8_file_path: "priv/apns/token.p8"
        },
        endpoint: "localhost",
        mode: :prod,
        use_2197: true,
        pool_size: 3,
        default_topic: "prod_topic1",
        tls_opts: []
      ]
    ]

    Application.stop(:mongoose_push)
    Application.stop(:sparrow)
    Application.put_env(:mongoose_push, :apns, apns_config)
    Application.ensure_all_started(:mongoose_push)

    assert :ok ==
             push(@test_token, %{
               :service => :apns,
               :alert => %{:title => "", :body => ""},
               mode: :dev
             })

    auth_type =
      last_activity(:apns)["request_headers"]["authorization"]
      |> String.slice(0..5)

    assert "bearer" == auth_type

    TestHelper.reload_app()
  end

  describe "tagged pools" do
    setup do
      apns_config = [
        dev1: [
          auth: %{
            type: :token,
            key_id: "fake_key",
            team_id: "fake_team",
            p8_file_path: "priv/apns/token.p8"
          },
          endpoint: "localhost",
          mode: :dev,
          use_2197: true,
          pool_size: 3,
          default_topic: "dev_topic1",
          tags: [:tag1, :tag2],
          tls_opts: []
        ],
        dev2: [
          auth: %{
            type: :token,
            key_id: "fake_key",
            team_id: "fake_team",
            p8_file_path: "priv/apns/token.p8"
          },
          endpoint: "localhost",
          mode: :dev,
          use_2197: true,
          pool_size: 3,
          default_topic: "prod_topic1",
          tags: [:tag2, :tag3],
          tls_opts: []
        ],
        prod1: [
          auth: %{
            type: :token,
            key_id: "fake_key",
            team_id: "fake_team",
            p8_file_path: "priv/apns/token.p8"
          },
          endpoint: "localhost",
          mode: :prod,
          use_2197: true,
          pool_size: 3,
          default_topic: "dev_topic1",
          tags: [:tag1, :tag2],
          tls_opts: []
        ],
        prod2: [
          auth: %{
            type: :token,
            key_id: "fake_key",
            team_id: "fake_team",
            p8_file_path: "priv/apns/token.p8"
          },
          endpoint: "localhost",
          mode: :prod,
          use_2197: true,
          pool_size: 3,
          default_topic: "prod_topic1",
          tags: [:tag2, :tag3],
          tls_opts: []
        ]
      ]

      fcm_config = [
        pool1: [
          appfile: "priv/fcm/token.json",
          endpoint: "localhost",
          pool_size: 5,
          mode: :prod,
          port: 4000,
          tags: [:tag1, :tag2, :tag3],
          tls_opts: []
        ],
        pool2: [
          appfile: "priv/fcm/token.json",
          endpoint: "localhost",
          pool_size: 4,
          mode: :dev,
          port: 4000,
          tags: [:tag2, :tag3, :tag4],
          tls_opts: []
        ]
      ]

      Application.stop(:mongoose_push)
      Application.stop(:sparrow)
      Application.put_env(:mongoose_push, :apns, apns_config)
      Application.put_env(:mongoose_push, :fcm, fcm_config)
      {:ok, _} = Application.ensure_all_started(:mongoose_push)
      :ok
    end

    test "are tagged and chosen correctly" do
      assert :dev1 == MongoosePush.Service.APNS.choose_pool(:dev, [:tag1])
      assert :dev1 == MongoosePush.Service.APNS.choose_pool(:dev, [:tag1, :tag2])
      assert :dev2 == MongoosePush.Service.APNS.choose_pool(:dev, [:tag3])
      assert :dev2 == MongoosePush.Service.APNS.choose_pool(:dev, [:tag2, :tag3])
      assert nil == MongoosePush.Service.APNS.choose_pool(:dev, [:tag1, :tag2, :tag3])

      assert :prod1 == MongoosePush.Service.APNS.choose_pool(:prod, [:tag1])
      assert :prod1 == MongoosePush.Service.APNS.choose_pool(:prod, [:tag1, :tag2])
      assert :prod2 == MongoosePush.Service.APNS.choose_pool(:prod, [:tag3])
      assert :prod2 == MongoosePush.Service.APNS.choose_pool(:prod, [:tag2, :tag3])
      assert nil == MongoosePush.Service.APNS.choose_pool(:prod, [:tag1, :tag2, :tag3])

      assert :pool1 == MongoosePush.Service.FCM.choose_pool(:prod)
      assert :pool1 == MongoosePush.Service.FCM.choose_pool(:prod, [:tag1])
      assert :pool1 == MongoosePush.Service.FCM.choose_pool(:prod, [:tag1, :tag2, :tag3])
      assert :pool2 == MongoosePush.Service.FCM.choose_pool(:dev)
      assert :pool2 == MongoosePush.Service.FCM.choose_pool(:dev, [:tag2])
      assert :pool2 == MongoosePush.Service.FCM.choose_pool(:dev, [:tag2, :tag3, :tag4])
      assert nil == MongoosePush.Service.FCM.choose_pool(:prod, [:tag2, :tag3, :tag4])
      assert nil == MongoosePush.Service.FCM.choose_pool(:dev, [:tag1, :tag2, :tag3])
      TestHelper.reload_app()
    end

    test "are integrated with APNS" do
      notification = %{
        :service => :apns,
        :alert => %{
          :title => "title",
          :body => "body"
        },
        :mode => :prod,
        :tags => [:tag2, :tag3],
        :data => %{
          "acme1" => "apns1",
          "acme2" => "apns2",
          "acme3" => "apns3"
        }
      }

      assert :ok == push(@test_token, notification)

      invalid_notification =
        notification
        |> Map.replace!(:tags, [:tag1, :tag2, :tag3])

      assert {:error, {:generic, :no_matching_pool}} == push(@test_token, invalid_notification)
      TestHelper.reload_app()
    end

    test "are integrated with FCM" do
      notification = %{
        :service => :fcm,
        :data => %{
          "acme1" => "fcm1",
          "acme2" => "fcm2",
          "acme3" => "fcm3"
        }
      }

      assert :ok == push(@test_token, notification)

      invalid_notification =
        notification
        |> Map.put(:tags, [:tag1, :tag2, :tag3, :tag4])

      assert {:error, {:generic, :no_matching_pool}} == push(@test_token, invalid_notification)
      TestHelper.reload_app()
    end
  end

  defp reset(:apns) do
    {:ok, conn} = get_connection(:apns)
    headers = headers("POST", "/reset")
    :h2_client.send_request(conn, headers, "")
    get_response(conn)
    :ok
  end

  defp reset(:fcm) do
    {:ok, conn} = get_connection(:fcm)
    headers = headers("POST", "/mock/reset")
    :h2_client.send_request(conn, headers, "")
    get_response(conn)
    :ok
  end

  defp fail_tokens(:apns, json) do
    {:ok, conn} = get_connection(:apns)
    payload = Poison.encode!(json)

    headers = headers("POST", "/error-tokens", payload)
    :h2_client.send_request(conn, headers, payload)
    get_response(conn)
    :ok
  end

  defp fail_tokens(:fcm, json) do
    {:ok, conn} = get_connection(:fcm)
    payload = Poison.encode!(json)

    headers = headers("POST", "/mock/error-tokens", payload)
    :h2_client.send_request(conn, headers, payload)
    get_response(conn)
    :ok
  end

  defp last_activity(:fcm) do
    {:ok, conn} = get_connection(:fcm)
    headers = headers("GET", "/mock/activity")
    :h2_client.send_request(conn, headers, "")

    get_response(conn)
    |> Poison.decode!()
    |> List.first()
  end

  defp last_activity(:apns) do
    {:ok, conn} = get_connection(:apns)
    headers = headers("GET", "/activity")
    :h2_client.send_request(conn, headers, "")

    get_response(conn)
    |> Poison.decode!()
    |> Map.get("logs")
    |> List.last()
  end

  defp headers(method, path, payload \\ "") do
    [
      {":method", method},
      {":authority", "localhost"},
      {":scheme", "https"},
      {":path", path},
      {"content-length", "#{byte_size(payload)}"},
      {"content-type", "application/json"}
    ]
  end

  defp get_connection(:apns) do
    :h2_client.start_link(:https, 'localhost', 2197, [])
  end

  defp get_connection(:fcm) do
    :h2_client.start_link(:https, 'localhost', 4000, [])
  end

  defp get_response(conn) do
    receive do
      {:END_STREAM, stream_id} ->
        {:ok, {_headers, body}} = :h2_client.get_response(conn, stream_id)
        Enum.join(body)
    end
  end

  defp push(token, notification), do: MongoosePush.push(token, notification)

  def delete_topic_from_config({pool_name, pool_config}) do
    case pool_config[:default_topic] do
      nil -> {pool_name, pool_config}
      _ -> {pool_name, List.keydelete(pool_config, :default_topic, 0)}
    end
  end

  def add_topic_to_config({pool_name, pool_config}) do
    if is_nil(pool_config[:default_topic]) do
      case pool_config[:mode] do
        :dev -> {pool_name, [{:default_topic, @dev_topic} | pool_config]}
        :prod -> {pool_name, [{:default_topic, @prod_topic} | pool_config]}
      end
    else
      {pool_name, pool_config}
    end
  end

  # FCM v1 requires "3.5s" format, need to convert back to integer
  defp convert_ttl(ttl) do
    ttl
    |> String.slice(0..-2)
    |> String.to_integer()
  end
end
