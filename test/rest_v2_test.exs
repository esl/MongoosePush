defmodule RestV2Test do
  use ExUnit.Case
  import Mock
  alias HTTPoison.Response
  doctest MongoosePush.API.V2

  @url "/v2/notification/f534534543"

  test "incorrect path returns 404" do
    assert 404 = post("/notification", %{})
    assert 404 = post("/v2/notification", %{})
    assert 404 = post("/v2/notifications/test", %{})
  end

  test "incorrect params returns 400" do
    assert 400 = post(@url, %{service: :apns})
    assert 400 = post(@url, %{service: :fcm})
    assert 400 = post(@url, %{service: :apns, body: "body"})
    assert 400 = post(@url, %{service: :fcm, title: "title"})
    assert 400 = post(@url, %{service: :fcm, body: "body", title: "title"})
    assert 400 = post(@url, %{service: "other", body: "body", title: "title"})
  end

  test "invalid method returns 405" do
    assert 405 = get("/v2/notification/test")
  end

  test "api crash returns 500" do
    with_mock MongoosePush, [push: fn(_, _) -> raise "oops" end] do
      assert 500 = post(@url, %{service: :fcm, alert: %{body: "body", title: "title"}})
    end
  end

  test "correct params return 200" do
    with_mock MongoosePush, [push: fn(_, _) -> :ok end] do
      assert 200 = post(@url, %{service: :apns,  alert: %{body: "body", title: "title"}})
      assert 200 = post(@url, %{service: :fcm,   alert: %{body: "body", title: "title"}})

      assert 200 = post(@url, %{service: :apns,  data: %{a1: "test", a2: "test"}})
      assert 200 = post(@url, %{service: :fcm,   data: %{a1: "test", a2: "test"}})
    end
  end

  test "push error returns 500" do
    with_mock MongoosePush, [push: fn(_, _) -> {:error, :something} end] do
      assert 500 = post(@url, %{service: :apns,  alert: %{body: "body", title: "title"}})
      assert 500 = post(@url, %{service: :fcm,   alert: %{body: "body", title: "title"}})
    end
  end

  test "unknown push error returns 500" do
    with_mock MongoosePush, [push: fn(_, _) -> {:error, {1, "unknown"}} end] do
      assert 500 = post(@url, %{service: :apns,  alert: %{body: "body", title: "title"}})
      assert 500 = post(@url, %{service: :fcm,   alert: %{body: "body", title: "title"}})
    end
  end

  test "api gets corrent request arguments" do
    with_mock MongoosePush, [push: fn(_, _) -> :ok end] do
      args = %{
        service: :fcm, mode: :dev, topic: "apns topic", priority: :high, mutable_content: false,
        alert: %{
          body: "body654", title: "title345",
          badge: 10, tag: "tag123", click_action: "on.click", sound: "sound.wav"
        }
      }
      assert 200 = post(@url, args)
      assert called MongoosePush.push("f534534543", args)
    end
  end

  test "api gets raw data payload" do
    with_mock MongoosePush, [push: fn(_, _) -> :ok end] do
      args = %{
        service: :fcm, mode: :dev, priority: :normal, mutable_content: true,
        alert: %{body: "body654", title: "title345"},
        data: %{"acme1" => "value1", "acme2" => "value2"}
      }
      assert 200 = post(@url, args)
      assert called MongoosePush.push("f534534543", args)
    end
  end

  defp post(path, json) do
     %Response{status_code: status_code} =
       HTTPoison.post!("https://localhost:8443" <> path, Poison.encode!(json),
                       [{"Content-Type", "application/json"}],
                       hackney: [:insecure])
     status_code
  end

  defp get(path) do
    %Response{status_code: status_code} =
      HTTPoison.get!("https://localhost:8443" <> path, [], hackney: [:insecure])
    status_code
  end

end
