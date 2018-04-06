defmodule MongoosePushTest do
  use ExUnit.Case
  use Quixir
  import Mock
  doctest MongoosePush

  @test_token "testdeviceid1234"
  @apns_priority_mapping %{normal: "5", high: "10"}

  setup do
    reset(:fcm)
    reset(:apns)
  end

  describe "apns topic" do
    test "is always set to the value provided with API using :dev mode" do
      assert :ok == push(@test_token, %{:service => :apns, :title => "", :body => "", mode: :dev,
                                        topic: "some_topic"})

      apns_request = last_activity(:apns)
      assert @test_token == apns_request["device_token"]
      assert "some_topic" == apns_request["request_headers"]["apns-topic"]
    end

    test "is always set to the value provided with API using :prod mode" do
      assert :ok == push(@test_token, %{:service => :apns, :title => "", :body => "", mode: :prod,
                                        topic: "some_topic"})

      apns_request = last_activity(:apns)
      assert @test_token == apns_request["device_token"]
      assert "some_topic" == apns_request["request_headers"]["apns-topic"]
    end

    test "defaults to value set in config using :dev mode" do
      with_mock(MongoosePush.Pools, [:passthrough], [
        pools_by_mode: fn(:apns, :dev) -> [:dev1] end
      ]) do
        assert :ok == push(@test_token, %{:service => :apns, :title => "", :body => "", mode: :dev})

        apns_request = last_activity(:apns)
        assert @test_token == apns_request["device_token"]
        assert "dev_topic" == apns_request["request_headers"]["apns-topic"]
      end
    end

    test "is not set if theres no default value in config nor certificate" do
      with_mock(MongoosePush.Pools, [:passthrough], [
        pools_by_mode: fn(:apns, :dev) -> [:dev2] end
      ]) do
        assert :ok == push(@test_token, %{:service => :apns, :title => "", :body => "", mode: :dev})

        apns_request = last_activity(:apns)
        assert @test_token == apns_request["device_token"]
        assert nil == apns_request["request_headers"]["apns-topic"]
      end
    end

    test "defaults to value set in config using :prod mode" do
      with_mock(MongoosePush.Pools, [:passthrough], [
        pools_by_mode: fn(:apns, :prod) -> [:prod1] end
      ]) do
        assert :ok == push(@test_token, %{:service => :apns, :title => "", :body => "", mode: :prod})

        apns_request = last_activity(:apns)
        assert @test_token == apns_request["device_token"]
        assert "prod1_override_topic" == apns_request["request_headers"]["apns-topic"]
      end
    end

    test "defaults to value extracted from cert using :prod mode" do
      with_mock(MongoosePush.Pools, [:passthrough], [
        pools_by_mode: fn(:apns, :prod) -> [:prod2] end
      ]) do
        assert :ok == push(@test_token, %{:service => :apns, :title => "", :body => "", mode: :prod})

        apns_request = last_activity(:apns)
        assert @test_token == apns_request["device_token"]
        assert "com.inakanetworks.Mangosta" == apns_request["request_headers"]["apns-topic"]
      end
    end
  end

  test "simple push to apns succeeds" do
    assert :ok == push("device_id",
                       %{:service => :apns, :title => "", :body => ""})
  end

  test "push to apns assign correct message fields" do
    ptest [
        device_token: string(min: 10, max: 15, chars: ?a..?z),
        title: string(min: 3, max: 15, chars: :ascii),
        body:  string(min: 10, max: 45, chars: :ascii),
        badge: int(min: 1, max: 20),
        sound: string(min: 3, max: 15, chars: :ascii),
        click_action: string(min: 3, max: 15, chars: :ascii),
        priority: choose(from: [value(:normal), value(:high)]),
        mutable_content: bool(),
      ], repeat_for: 10 do

      notification =
        %{:service => :apns,
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
        body:  string(min: 10, max: 45, chars: :ascii),
        tag: string(min: 3, max: 15, chars: :ascii),
        sound: string(min: 3, max: 15, chars: :ascii),
        click_action: string(min: 3, max: 15, chars: :ascii),
        priority: choose(from: [value(:normal), value(:high)]),
      ], repeat_for: 10 do

      notification =
        %{:service => :fcm,
          :priority => priority,
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

      IO.puts push(device_token, notification)
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
    end
  end

  test "push to fcm assign correct message fields when sending silent notification" do
    notification =
      %{:service => :fcm,
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
    notification =
      %{:service => :apns,
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
    notification =
      %{:service => :fcm,
        :alert => %{
          :title => "title value",
          :body => "body value",
          :click_action => "click.action",
          :tag => "tag value"
        }
      }
    fail_tokens(:fcm, [%{device_token: "androidtestdeviceid65", status: 200,
                         reason: "InvalidRegistration"}])

    assert {:error, :invalid_device_token} = push("androidtestdeviceid65", notification)
  end

  test "push to apns allows choosing mode" do
    notification =
      %{:service => :apns,
        :alert => %{
          :title => "title value",
          :body => "body value",
        }
      }
    dev_notification = Map.put(notification, :mode, :dev)
    prod_notification = Map.put(notification, :mode, :prod)

    # Default should be mode: :prod
    with_mock MongoosePush.Pools, [:passthrough], [] do
      assert :ok = push("androidtestdeviceid65", notification)
      assert called(MongoosePush.Pools.select_worker(:_, :prod))
    end

    with_mock MongoosePush.Pools, [:passthrough], [] do
      assert :ok = push("androidtestdeviceid65", dev_notification)
      assert called(MongoosePush.Pools.select_worker(:_, :dev))
    end

    with_mock MongoosePush.Pools, [:passthrough], [] do
      assert :ok = push("androidtestdeviceid65", prod_notification)
      assert called(MongoosePush.Pools.select_worker(:_, :prod))
    end
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
    |> Poison.decode!
    |> Map.get("logs")
    |> List.last
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
end
