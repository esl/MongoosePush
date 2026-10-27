# `MongoosePush.Service.FCM.Pool.Supervisor`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mongoose_push/service/fcm/pool/supervisor.ex#L1)

This module is responsible for setting up Sparrow's FCM Supervisor

# `child_spec`

Returns a specification to start this module under a supervisor.

See `Supervisor`.

# `start_link`

```elixir
@spec start_link([MongoosePush.Application.pool_definition()]) ::
  Supervisor.on_start()
```

