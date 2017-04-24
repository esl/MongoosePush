defmodule MongoosePush.Pools do
  @moduledoc """
  This module is responsible for worker pools management. It provides several
  utility functions that help with e.g. selecting workers for given pool of the
  service.
  """
  import MongoosePush.Application

  @doc "Returns size of the pool"
  @spec pool_size(MongoosePush.service, atom) :: integer
  def pool_size(service, name) do
    config = pools_config(service)
    config[name][:pool_size]
  end

  @doc "Returns worker name based of the service type, worker name and its id"
  @spec worker_name(atom, atom, integer) :: atom
  def worker_name(type, name, num), do: String.to_atom(~s"#{type}_#{name}_#{num}")

  @doc "Returns lists of pool names that have selected `:mode` set"
  @spec pools_by_mode(MongoosePush.service, MongoosePush.mode) :: list(atom)
  def pools_by_mode(:fcm = service, _mode) do
    config = pools_config(service)
    Enum.map(config, &(elem(&1, 0)))
  end

  def pools_by_mode(:apns = service, mode) do
    config = pools_config(service)

    config
    |> Enum.group_by(fn({_pool_name, pool_config}) ->
        pool_config[:mode]
      end)
    |> Map.get(mode)
    |> Keyword.keys()
  end

  @doc "Return random worker name for given service and with given `:mode` set"
  @spec select_worker(MongoosePush.service, MongoosePush.mode) :: atom
  def select_worker(service, mode) do
    [pool | _] = __MODULE__.pools_by_mode(service, mode)
    worker_name(service, pool, Enum.random(1..pool_size(service, pool)))
  end
end
