# `MongoosePush.Service.APNS.ErrorHandler`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mongoose_push/service/apns/error_handler.ex#L1)

Module responsible for handling errors returned by APNS service

# `translate_error_reason`

```elixir
@spec translate_error_reason(
  MongoosePush.Service.error_reason()
  | {MongoosePush.Service.error_reason(), any()}
) :: MongoosePush.Service.error()
```

