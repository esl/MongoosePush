# `MongoosePush.Service.FCM`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mongoose_push/service/fcm.ex#L1)

FCM (Firebase Cloud Messaging) service provider implementation.

# `choose_pool`

```elixir
@spec choose_pool(MongoosePush.mode(), [any()]) ::
  MongoosePush.Application.pool_name() | nil
```

# `prepare_notification`

```elixir
@spec prepare_notification(String.t(), MongoosePush.request(), atom()) ::
  MongoosePush.Service.notification()
```

# `push`

```elixir
@spec push(
  MongoosePush.Service.notification(),
  String.t(),
  MongoosePush.Application.pool_name(),
  MongoosePush.Service.options()
) ::
  :ok | {:error, MongoosePush.Service.error()} | {:error, MongoosePush.error()}
```

# `supervisor_entry`

```elixir
@spec supervisor_entry([MongoosePush.Application.pool_definition()] | nil) ::
  {module(), term()}
```

# `unify_error`

```elixir
@spec unify_error(MongoosePush.Service.error_reason()) ::
  MongoosePush.Service.error() | MongoosePush.error()
```

