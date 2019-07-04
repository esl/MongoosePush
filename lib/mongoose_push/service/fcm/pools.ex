defmodule MongoosePush.Service.FCM.Pools do
  @moduledoc """
  This module is responsible for worker pools management. It provides several
  utility functions that help with e.g. selecting workers for given pool of the
  service.
  """
  alias MongoosePush.Application

  @doc "Returns size of the pool"
  @spec pool_size(MongoosePush.service(), atom) :: integer
  def pool_size(service, name) do
    config = Application.pools_config(service)
    config[name][:pool_size]
  end

  @doc "Returns worker name based of the service type, worker name and its id"
  @spec worker_name(atom, atom, integer) :: atom
  def worker_name(type, name, num), do: String.to_atom(~s"#{type}_#{name}_#{num}")

  @doc "Returns lists of pool names that have selected `:mode` set"
  @spec pools_by_mode() :: list(atom)
  def pools_by_mode() do
    config = Application.pools_config(:fcm)
    Enum.map(config, &elem(&1, 0))
  end

  @doc "Return random worker name for given service and with given `:mode` set"
  @spec select_worker() :: atom
  def select_worker() do
    [pool | _] = __MODULE__.pools_by_mode()
    worker_name(:fcm, pool, Enum.random(1..pool_size(:fcm, pool)))
  end
end
