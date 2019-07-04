defmodule MongoosePushTest do
  use ExUnit.Case, async: false
  use Quixir
  import Mock
  doctest MongoosePush

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
      with_mock(MongoosePush.Service.FCM.Pools, [:passthrough], pools_by_mode: fn -> [:dev1] end) do
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
    end

    test "defaults to value set in config using :prod mode" do
      with_mock(MongoosePush.Service.FCM.Pools, [:passthrough], pools_by_mode: fn -> [:prod1] end) do
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
      with_mock(MongoosePush.Service.FCM.Pools, [:passthrough], pools_by_mode: fn -> [:prod2] end) do
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
    end

    test "is not set if theres no default value in config nor certificate" do
      with_mock(MongoosePush.Service.FCM.Pools, [:passthrough], pools_by_mode: fn -> [:dev2] end) do
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
      fcm_request = last_activity(:fcm)
      fcm_data = fcm_request["request_data"]["notification"]
      fcm_custom = fcm_request["request_data"]["data"]

      assert device_token == fcm_request["device_token"]
      assert Atom.to_string(priority) == fcm_request["request_data"]["priority"]

      assert notification.alert[:title] == fcm_data["title"]
      assert notification.alert[:body] == fcm_data["body"]
      assert notification.alert[:click_action] == fcm_data["click_action"]
      assert notification.alert[:tag] == fcm_data["tag"]
      assert notification.alert[:sound] == fcm_data["sound"]
      assert notification[:data] == fcm_custom
      assert notification[:time_to_live] == fcm_request["request_data"]["time_to_live"]
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
    fcm_request = last_activity(:fcm)
    fcm_data = fcm_request["request_data"]["notification"]
    fcm_custom = fcm_request["request_data"]["data"]

    assert "androidtestdeviceid12" == fcm_request["device_token"]
    assert nil == fcm_data["title"]
    assert nil == fcm_data["body"]
    assert nil == fcm_data["click_action"]
    assert nil == fcm_data["tag"]
    assert notification[:data] == fcm_custom
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
      %{device_token: "androidtestdeviceid65", status: 200, reason: "InvalidRegistration"}
    ])

    assert {:error, :invalid_device_token} = push("androidtestdeviceid65", notification)
  end

  defp reset(service) do
    {:ok, conn} = get_connection(service)
    headers = headers("POST", "/reset")
    :h2_client.send_request(conn, headers, "")
    get_response(conn)
    :ok
  end

  defp fail_tokens(service, json) do
    {:ok, conn} = get_connection(service)
    payload = Poison.encode!(json)

    headers = headers("POST", "/error-tokens", payload)
    :h2_client.send_request(conn, headers, payload)
    get_response(conn)
    :ok
  end

  defp last_activity(service) do
    {:ok, conn} = get_connection(service)
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
    :h2_client.start_link(:https, 'localhost', 443, [])
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
end
