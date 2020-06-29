# Local build

## Prerequisites

* Elixir 1.5+ (http://elixir-lang.org/install.html)
* Erlang/OTP 19.3+
  > NOTE: Some Erlang/OTP 20.x releases / builds contain TLS bug that prevents connecting to APNS servers.
  > When building with this Erlang version, please make sure that MongoosePushRuntimeTest test suite passes.
  > It is however highly recommended to build MongoosePush with Erlang/OTP 21.x.
* Rebar3 (just enter ```mix local.rebar```)



## Production release

Build step is really easy. Just type in root of the repository:
```bash
MIX_ENV=prod mix do deps.get, compile, certs.dev, distillery.release
```

After this step you may try to run the service via:
```bash
_build/prod/rel/mongoose_push/bin/mongoose_push foreground
```

Yeah, I know... It crashed. Running this service is fast and simple but unfortunately you can't have push notifications without properly configured `FCM` and/or `APNS` service. You can find out how to properly configure it in `Configuration` section of this README.

## Development release

Build step is really easy. Just type in root of the repository:
```bash
MIX_ENV=dev mix do deps.get, compile, certs.dev, distillery.release
```

Development release is by default configured to connect to local APNS / FCM mock. This configuration may be changed as needed
in `config/dev.exs` file.
For now, let's just start those mocks so that we can use default dev configuration:
```bash
docker-compose -f test/docker/docker-compose.mocks.yml up -d
```

After this step you may try to run the service via:
```bash
_build/dev/rel/mongoose_push/bin/mongoose_push console
```

