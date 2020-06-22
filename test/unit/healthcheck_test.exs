defmodule MongoosePushWeb.HealthcheckTest do
  alias MongoosePush.Support.API
  use ExUnit.Case, async: false
  import Mox

  setup :verify_on_exit!

  setup do
    TestHelper.reload_app()
  end

  test "Successful connection to services" do
    {200, _, body} = API.get("/healthcheck")
    pools = Jason.decode!(body)

    fcm_pools =
      :mongoose_push
      |> Application.get_env(:fcm)
      |> Enum.map(fn {name, info} ->
        {name, Keyword.get(info, :pool_size)}
      end)

    apns_pools =
      :mongoose_push
      |> Application.get_env(:apns)
      |> Enum.map(fn {name, info} ->
        {name, Keyword.get(info, :pool_size)}
      end)

    for {pool_name, worker_count} <- fcm_pools ++ apns_pools do
      pool_info = %{
        "pool" => Atom.to_string(pool_name),
        "connection_status" => List.duplicate("connected", worker_count)
      }

      assert true == Enum.member?(pools, pool_info)
    end
  end

  describe "Unsuccessful FCM connection" do
    setup do
      old_config = Application.fetch_env!(:mongoose_push, :fcm)

      new_config =
        old_config
        |> Enum.map(fn {pool_name, pool_info} ->
          # We simulate broken FCM connection by changing the port
          {pool_name, Keyword.update(pool_info, :port, 4444, &(&1 + 1))}
        end)

      Application.stop(:mongoose_push)
      Application.load(:mongoose_push)
      Application.put_env(:mongoose_push, :fcm, new_config)
      Application.start(:mongoose_push)
    end

    test "is reflected in heathcheck endpoint" do
      {200, _, body} = API.get("/healthcheck")
      pools = Jason.decode!(body)

      fcm_pools =
        :mongoose_push
        |> Application.get_env(:fcm)
        |> Enum.map(fn {name, info} ->
          {name, Keyword.get(info, :pool_size)}
        end)

      apns_pools =
        :mongoose_push
        |> Application.get_env(:apns)
        |> Enum.map(fn {name, info} ->
          {name, Keyword.get(info, :pool_size)}
        end)

      for {pool_name, worker_count} <- apns_pools do
        pool_info = %{
          "pool" => Atom.to_string(pool_name),
          "connection_status" => List.duplicate("connected", worker_count)
        }

        assert true == Enum.member?(pools, pool_info)
      end

      for {pool_name, worker_count} <- fcm_pools do
        pool_info = %{
          "pool" => Atom.to_string(pool_name),
          "connection_status" => List.duplicate("disconnected", worker_count)
        }

        assert true == Enum.member?(pools, pool_info)
      end
    end
  end

  describe "Unsuccessful APNS and FCM connection" do
    setup do
      old_fcm_config = Application.fetch_env!(:mongoose_push, :fcm)

      new_fcm_config =
        old_fcm_config
        |> Enum.map(fn {pool_name, pool_info} ->
          # We simulate broken FCM connection by changing the port
          {pool_name, Keyword.update(pool_info, :port, 4444, &(&1 + 1))}
        end)

      old_apns_config = Application.fetch_env!(:mongoose_push, :apns)

      new_apns_config =
        old_apns_config
        |> Enum.map(fn {pool_name, pool_info} ->
          # We simulate broken APNS connection by changing the port
          {pool_name, Keyword.update(pool_info, :use_2197, false, &(!&1))}
        end)

      Application.stop(:mongoose_push)
      Application.load(:mongoose_push)
      Application.put_env(:mongoose_push, :fcm, new_fcm_config)
      Application.put_env(:mongoose_push, :apns, new_apns_config)
      Application.start(:mongoose_push)
    end

    test "is reflected in heathcheck endpoint" do
      {503, _, body} = API.get("/healthcheck")
      pools = Jason.decode!(body)

      fcm_pools =
        :mongoose_push
        |> Application.get_env(:fcm)
        |> Enum.map(fn {name, info} ->
          {name, Keyword.get(info, :pool_size)}
        end)

      apns_pools =
        :mongoose_push
        |> Application.get_env(:apns)
        |> Enum.map(fn {name, info} ->
          {name, Keyword.get(info, :pool_size)}
        end)

      for {pool_name, worker_count} <- apns_pools do
        pool_info = %{
          "pool" => Atom.to_string(pool_name),
          "connection_status" => List.duplicate("disconnected", worker_count)
        }

        assert true == Enum.member?(pools, pool_info)
      end

      for {pool_name, worker_count} <- fcm_pools do
        pool_info = %{
          "pool" => Atom.to_string(pool_name),
          "connection_status" => List.duplicate("disconnected", worker_count)
        }

        assert true == Enum.member?(pools, pool_info)
      end
    end
  end
end
