# `MongoosePush.Service`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mongoose_push/service.ex#L1)

Generic interface for push notifications services.

# `error`

```elixir
@type error() :: {error_type(), error_reason()}
```

Error tuple with unified internal representation and exact reason returned by service

# `error_reason`

```elixir
@type error_reason() :: atom()
```

# `error_type`

```elixir
@type error_type() ::
  :invalid_request
  | :internal_config
  | :auth
  | :unregistered
  | :too_many_requests
  | :unspecified
  | :service_internal
  | :payload_too_large
  | :unknown
```

# `notification`

```elixir
@type notification() :: term()
```

# `options`

```elixir
@type options() :: [Keyword.t()]
```

# `choose_pool`

```elixir
@callback choose_pool(MongoosePush.mode(), [atom()]) ::
  MongoosePush.Application.pool_name() | nil
```

# `prepare_notification`

```elixir
@callback prepare_notification(
  String.t(),
  MongoosePush.request(),
  MongoosePush.Application.pool_name()
) ::
  notification()
```

# `push`

```elixir
@callback push(
  notification(),
  String.t(),
  MongoosePush.Application.pool_name(),
  options()
) ::
  :ok | {:error, error()} | {:error, MongoosePush.error()}
```

# `supervisor_entry`

```elixir
@callback supervisor_entry([MongoosePush.Application.pool_definition()] | nil) ::
  {module(), term()}
```

