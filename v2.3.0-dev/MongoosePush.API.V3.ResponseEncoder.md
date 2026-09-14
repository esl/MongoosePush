# `MongoosePush.API.V3.ResponseEncoder`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mongoose_push/api/v3/response_encoder.ex#L1)

Module for handling internal responses to V3 HTTP2 codes

# `to_status`

```elixir
@spec to_status(
  :ok
  | {:error, MongoosePush.Service.error()}
  | {:error, MongoosePush.error()}
) ::
  {non_neg_integer(), %{reason: atom() | String.t()} | nil}
```

