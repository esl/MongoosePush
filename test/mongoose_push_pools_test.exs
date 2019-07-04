defmodule MongoosePushPoolsTest do
  use ExUnit.Case, async: false
  import MongoosePush.Service.FCM.Pools
  doctest MongoosePush.Service.FCM.Pools

  setup do
    # Validate config/text.exs that is need for this test suite
    apns_pools = Keyword.keys(Application.get_env(:mongoose_push, :apns))
    [:dev1, :dev2, :prod1, :prod2] = Enum.sort(apns_pools)

    fcm_pools = Keyword.keys(Application.get_env(:mongoose_push, :fcm))
    [:default] = fcm_pools
    TestHelper.reload_app()
  end

  test "worker name" do
    assert :apns_name1_1 == worker_name(:apns, :name1, 1)
    assert :fcm_name2_12 == worker_name(:fcm, :name2, 12)
  end

  test "pool groups" do
    assert [:default] == pools_by_mode()
  end

  test "pool size" do
    assert 1 == pool_size(:apns, :dev1)
    assert 2 == pool_size(:apns, :prod1)
    assert 3 == pool_size(:apns, :dev2)
    assert 4 == pool_size(:apns, :prod2)
    assert 5 == pool_size(:fcm, :default)
  end
end
