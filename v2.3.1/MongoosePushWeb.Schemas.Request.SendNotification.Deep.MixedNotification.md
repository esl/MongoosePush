# `MongoosePushWeb.Schemas.Request.SendNotification.Deep.MixedNotification`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mongoose_push_web/schemas/request/send_notification/deep/mixed_notification.ex#L1)

Request.SendNotification.Deep.MixedNotification

In this request both alert and data fields are mandatory.

# `t`

```elixir
@type t() :: %MongoosePushWeb.Schemas.Request.SendNotification.Deep.MixedNotification{
  alert: term(),
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

