defmodule MongoosePushApplicationTest do
  use ExUnit.Case, async: false
  import MongoosePush.Service.FCM.Pools
  doctest MongoosePush.Application

  setup do
    # Validate config/text.exs that is need for this test suite
    apns_pools = Keyword.keys(Application.get_env(:mongoose_push, :apns))
    [:dev1, :dev2, :prod1, :prod2] = Enum.sort(apns_pools)

    fcm_pools = Keyword.keys(Application.get_env(:mongoose_push, :fcm))
    [:default] = fcm_pools
    TestHelper.reload_app()
  end

  test "pools online" do
    {_, apns_pid, _, _} =
      Supervisor.which_children(MongoosePush.Supervisor)
      |> List.keyfind(:apns_supervisor, 0)

    assert Process.alive?(apns_pid)

    {_, fcm_pid, _, _} =
      Supervisor.which_children(MongoosePush.Supervisor)
      |> List.keyfind(:fcm_pool_supervisor, 0)

    assert Process.alive?(fcm_pid)
  end

  test "pools have correct size" do
    assert nil == Process.whereis(worker_name(:apns, :dev1, 2))
    assert nil == Process.whereis(worker_name(:apns, :prod1, 3))
    assert nil == Process.whereis(worker_name(:apns, :dev2, 4))
    assert nil == Process.whereis(worker_name(:apns, :prod2, 5))
    assert nil == Process.whereis(worker_name(:fcm, :default, 6))
  end

  test "application starts and stops" do
    :ok = Application.stop(:mongoose_push)
    :ok = Application.start(:mongoose_push, :temporary)
  end

  test "workers are stoped along with the application" do
    :ok = Application.stop(:mongoose_push)
    assert nil == Process.whereis(worker_name(:apns, :dev1, 1))
    assert nil == Process.whereis(worker_name(:apns, :prod1, 1))
    assert nil == Process.whereis(worker_name(:apns, :dev2, 1))
    assert nil == Process.whereis(worker_name(:apns, :prod2, 1))
    assert nil == Process.whereis(worker_name(:fcm, :default, 1))
    :ok = Application.start(:mongoose_push, :temporary)
  end
end
