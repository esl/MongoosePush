# `MongoosePush.API.V1.ResponseEncoder`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mongoose_push/api/v1/response_encoder.ex#L1)

Module for handling internal responses to V1 HTTP2 codes

# `to_status`

```elixir
@spec to_status(
  :ok
  | {:error, MongoosePush.Service.error()}
  | {:error, MongoosePush.error()}
) ::
  {non_neg_integer(), %{details: atom() | String.t()} | nil}
```

