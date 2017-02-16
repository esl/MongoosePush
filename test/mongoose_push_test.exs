defmodule MongoosePushTest do
  use ExUnit.Case
  import MongoosePush
  import Mock
  doctest MongoosePush

  setup do
    reset(:fcm)
    reset(:apns)
  end

  test "simple push to apns succeeds" do
    assert :ok == push("device_id",
                       %{:service => :apns, :title => "", :body => ""})
  end

  test "push to apns assign correct message fields" do
    notification =
      %{:service => :apns,
        :title => "title value",
        :body => "body value",
        :badge => 5,
        :click_action => "click.action"
      }

    assert :ok == push("testdeviceid1234", notification)

    apns_request = last_activity(:apns)
    aps_data = apns_request["request_data"]["aps"]

    assert "testdeviceid1234" == apns_request["device_token"]
    assert notification[:title] == aps_data["alert"]["title"]
    assert notification[:body] == aps_data["alert"]["body"]
    assert notification[:badge] == aps_data["badge"]
    assert notification[:click_action] == aps_data["category"]

  end

  test "push to fcm assign correct message fields" do
    notification =
      %{:service => :fcm,
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"
      }

    assert :ok == push("androidtestdeviceid12", notification)
    fcm_request = last_activity(:fcm)
    fcm_data = fcm_request["request_data"]["notification"]

    assert "androidtestdeviceid12" == fcm_request["device_token"]
    assert notification[:title] == fcm_data["title"]
    assert notification[:body] == fcm_data["body"]
    assert notification[:click_action] == fcm_data["click_action"]
    assert notification[:tag] == fcm_data["tag"]

  end

  test "push to fcm with unknown token fails" do
    notification =
      %{:service => :fcm,
        :title => "title value",
        :body => "body value",
        :click_action => "click.action",
        :tag => "tag value"
      }
    fail_tokens(:fcm, [%{device_token: "androidtestdeviceid65", status: 200,
                         reason: "InvalidRegistration"}])

    assert {:error, _} = push("androidtestdeviceid65", notification)
  end

  test "push to apns allows choosing mode" do
    notification =
      %{:service => :apns,
        :title => "title value",
        :body => "body value",
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
    Kadabra.post(conn, "/reset", "")
    get_response()
    :ok
  end

  defp fail_tokens(service, json) do
    {:ok, conn} = get_connection(service)
    payload = Poison.encode!(json)

    headers = [
      {":method", "POST"},
      {":path", "/error-tokens"},
      {"content-length", "#{byte_size(payload)}"},
      {"content-type", "application/json"}
    ]
    Kadabra.request(conn, headers, payload)
    get_response()
    :ok
  end

  defp last_activity(service) do
    {:ok, conn} = get_connection(service)
    Kadabra.get(conn, "/activity")
    get_response()
    |> Poison.decode!
    |> Map.get("logs")
    |> List.last
  end

  defp get_connection(:apns) do
    Kadabra.open('localhost', :https, [port: 2197])
  end

  defp get_connection(:fcm) do
    Kadabra.open('localhost', :https, [port: 443])
  end

  defp get_response() do
    receive do
      {:end_stream, %Kadabra.Stream{body: body}} ->
        body
    end
  end
end
