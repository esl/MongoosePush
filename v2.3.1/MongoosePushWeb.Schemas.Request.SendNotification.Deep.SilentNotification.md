# `MongoosePushWeb.Schemas.Request.SendNotification.Deep.SilentNotification`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mongoose_push_web/schemas/request/send_notification/deep/silent_notification.ex#L1)

Request.SendNotification.Deep.SilentNotification

In this request data field is mandatory.

# `t`

```elixir
@type t() ::
  %MongoosePushWeb.Schemas.Request.SendNotification.Deep.SilentNotification{
    data: term(),
    mode: term(),
    mutable_content: term(),
    priority: term(),
    service: term(),
    tags: term(),
    time_to_live: term(),
    topic: term()
  }
```

# `schema`

