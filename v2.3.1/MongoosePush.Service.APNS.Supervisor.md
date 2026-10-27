# `MongoosePush.Service.APNS.Supervisor`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mongoose_push/service/apns/supervisor.ex#L1)

APNS module supervising Sparrow's PoolSupervisor and APNS State

# `child_spec`

Returns a specification to start this module under a supervisor.

See `Supervisor`.

# `start_link`

```elixir
@spec start_link([MongoosePush.Application.pool_definition()]) ::
  Supervisor.on_start()
```

