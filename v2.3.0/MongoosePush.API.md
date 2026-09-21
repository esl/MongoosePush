# `MongoosePush.API`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mongoose_push/api.ex#L1)

# `to_status`

```elixir
@callback to_status(:ok | {:error, term()}) ::
  {non_neg_integer(),
   %{details: atom() | String.t()} | %{reason: atom() | String.t()} | nil}
```

