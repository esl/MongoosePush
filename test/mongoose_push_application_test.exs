defmodule MongoosePushApplicationTest do
  use ExUnit.Case
  import MongoosePush.Application
  doctest MongoosePush.Application

  test "worker name" do
    assert :apns_name1_1 == worker_name(:apns, :name1, 1)
    assert :fcm_name2_12 == worker_name(:fcm, :name2, 12)
  end

  test "pool groups" do
    assert [:dev1, :dev2] == pools_by_mode(:apns, :dev)
    assert [:prod1, :prod2] == pools_by_mode(:apns, :prod)
    assert [:prod] == pools_by_mode(:fcm, :prod)
  end

  test "pool size" do
    assert 1 == pool_size(:apns, :dev1)
    assert 2 == pool_size(:apns, :prod1)
    assert 3 == pool_size(:apns, :dev2)
    assert 4 == pool_size(:apns, :prod2)
    assert 5 == pool_size(:fcm, :prod)
  end

  test "pools online" do
    assert Process.alive?(Process.whereis(worker_name(:apns, :prod1, 1)))
    assert Process.alive?(Process.whereis(worker_name(:apns, :prod1, 2)))

    assert Process.alive?(Process.whereis(worker_name(:apns, :prod2, 1)))
    assert Process.alive?(Process.whereis(worker_name(:apns, :prod2, 4)))

    assert Process.alive?(Process.whereis(worker_name(:apns, :dev1, 1)))

    assert Process.alive?(Process.whereis(worker_name(:apns, :dev2, 1)))
    assert Process.alive?(Process.whereis(worker_name(:apns, :dev2, 3)))

    assert Process.alive?(Process.whereis(worker_name(:fcm, :prod, 1)))
    assert Process.alive?(Process.whereis(worker_name(:fcm, :prod, 5)))
  end

  test "pools have corrent size" do
    assert nil == Process.whereis(worker_name(:apns, :dev1, 2))
    assert nil == Process.whereis(worker_name(:apns, :prod1, 3))
    assert nil == Process.whereis(worker_name(:apns, :dev2, 4))
    assert nil == Process.whereis(worker_name(:apns, :prod2, 5))
    assert nil == Process.whereis(worker_name(:fcm, :prod, 6))
  end

  test "application starts and stops" do
    ok = Application.stop(:mongoose_push)
    ok = Application.start(:mongoose_push, :temporary)
  end

  test "workers are stoped along with the application" do
    ok = Application.stop(:mongoose_push)
    assert nil == Process.whereis(worker_name(:apns, :dev1, 1))
    assert nil == Process.whereis(worker_name(:apns, :prod1, 1))
    assert nil == Process.whereis(worker_name(:apns, :dev2, 1))
    assert nil == Process.whereis(worker_name(:apns, :prod2, 1))
    assert nil == Process.whereis(worker_name(:fcm, :prod, 1))
  end
end
