# `mix certs.dev`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mix/tasks/certs_dev.ex#L1)

Generate fake certs (placeholders) for `HTTPS` endpoint and `APNS` service.

Please be aware that `APNS` requires valid Apple Developer certificates, so it
will not accept those fake certificates. Generated certificates may be used
only with mock APNS service (like one provided by docker
`mobify/apns-http2-mock-server`).

# `run`

```elixir
@spec run(term()) :: :ok
```

