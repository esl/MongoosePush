# `MongoosePush.Service.FCM.Pools`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mongoose_push/service/fcm/pools.ex#L1)

This module is responsible for worker pools management. It provides several
utility functions that help with e.g. selecting workers for given pool of the
service.

# `pool_size`

```elixir
@spec pool_size(MongoosePush.service(), atom()) :: integer()
```

Returns size of the pool

# `pools_by_mode`

```elixir
@spec pools_by_mode() :: [atom()]
```

Returns lists of pool names that have selected `:mode` set

# `select_worker`

```elixir
@spec select_worker() :: atom()
```

Return random worker name for given service and with given `:mode` set

# `worker_name`

```elixir
@spec worker_name(atom(), atom(), integer()) :: atom()
```

Returns worker name based of the service type, worker name and its id
