# MongoosePush

[![Build Status](https://travis-ci.org/esl/MongoosePush.svg?branch=master)](https://travis-ci.org/esl/MongoosePush) [![Coverage Status](https://coveralls.io/repos/github/esl/MongoosePush/badge.svg?branch=master)](https://coveralls.io/github/esl/MongoosePush?branch=master) [![Ebert](https://ebertapp.io/github/esl/MongoosePush.svg)](https://ebertapp.io/github/esl/MongoosePush)

**MongoosePush** is a simple, **RESTful** service written in **Elixir**, providing ability to **send push
notifications** to `FCM` (Firebase Cloud Messaging) and/or
`APNS` (Apple Push Notification Service) via their `HTTP/2` API.

## Quick start

### Docker

#### Running from DockerHub

We provide prebuilt MongoosePush images. Configuration requires either an FCM token, APNS certificates or an APNS token. Depending on your usecase, you can have some or all of them in a standalone MongoosePush instance or using a docker container.
For the full configuration you need to set the following directory structure up:
* priv/
    * ssl/
      * rest_cert.pem - The HTTP endpoint certificate
      * rest_key.pem - private key for the HTTP endpoint certificate (has to be unencrypted)
    * apns/
      * prod_cert.pem - Production APNS app certificate
      * prod_key.pem - Production APNS app certificate's private key (has to be unencrypted)
      * dev_cert.pem - Development APNS app certificate
      * dev_key.pem - Development APNS app certificate's private key (has to be unencrypted)
      * token.p8 - `APNS` authentication token
    * fcm/
      * token.json - `FCM` service account JSON file

If you want to use `APNS` token authentication you need to provide token and set `key_id` and `team_id` environmental variables. To see how to obtain token and `key_id` read:
https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_token_based_connection_to_apns
To see how to obtain `team_id` read: https://www.mobiloud.com/help/knowledge-base/ios-app-transfer/
`FCM` JSON file can be generated by Firebase console (https://console.firebase.google.com). Go to your project -> `Project Settings` -> `Service accounts` -> `Generate new private key`
Assuming that you have the `priv` directory with all ceriticates and fcm token in current directory, then you may start MongoosePush with the following command:

```bash
docker run -v `pwd`/priv:/opt/app/priv \
  -e PUSH_HTTPS_CERTFILE="/opt/app/priv/ssl/rest_cert.pem" \
  -e PUSH_HTTPS_KEYFILE="/opt/app/priv/ssl/rest_key.pem" \
  -it --rm mongooseim/mongoose-push:latest
```

#### Building

Building docker is really easy, just type:

```bash
docker build . -t mpush:latest
```

As a result of this command you get access to `mpush:latest` docker image. You may run it by typing:

```bash
docker run -it --rm mpush:latest foreground
```

The docker image that you have just built, exposes the port `8443` for the HTTP API of MongoosePush. It contains a `VOLUME` for path */opt/app* - it is handy for injecting `APNS` and `HTTP API` certificates since by default the docker image comes with test, self-signed certificates.

#### Configuration (basic)

The docker image of MongoosePush contains common, basic configuration that is generated from `config/prod.exs`. All useful options may be overridden via system environmental variables. Below there's a full list of the variables you may set while running docker (via `docker -e` switch), but if there's something you feel, you need to change other then that, then you need to prepare your own `config/prod.exs` before image build.

Environmental variables to configure production release:
##### Settings for HTTP endpoint:
* `PUSH_HTTPS_BIND_ADDR` - Bind IP address of the HTTP endpoint. Default value in prod release is "127.0.0.1", but docker overrides this with "0.0.0.0"
* `PUSH_HTTPS_PORT` - The port of the MongoosePush HTTP endpoint. Please note that docker exposes only `8443` port, so changing this setting is not recommended
* `PUSH_HTTPS_KEYFILE` - Path to a PEM keyfile used for HTTP endpoint. This path should be either absolute or relative to root of the release (in the Docker container that's `/opt/app`). Default: `priv/ssl/fake_key.pem`.
* `PUSH_HTTPS_CERTFILE` - Path to a PEM certfile used for HTTP endpoint. This path should be either absolute or relative to root of the release (in the Docker container that's `/opt/app`). Default: `priv/ssl/fake_cert.pem`.
* `PUSH_HTTPS_ACCEPTORS` - Number of TCP acceptors to start

##### General settings:
* `PUSH_LOGLEVEL` - `debug`/`info`/`warn`/`error` - Log level of the application. `info` is the default one
* `PUSH_FCM_ENABLED` - `true`/`false` - Enable or disable `FCM` support. Enabled by default
* `PUSH_APNS_ENABLED` - `true`/`false` - Enable or disable `APNS` support. Enabled by default
* `TLS_SERVER_CERT_VALIDATION` - `true`/`false` - Enable or distable TLS
  options for both FCM and APNS.
* `PUSH_OPENAPI_EXPOSE_SPEC` - `true`/`false` - Enable or disable OpenAPI specification endpoint support. If enabled, it will be available on `/swagger.json` HTTP path. Disabled by default
* `PUSH_OPENAPI_EXPOSE_UI` - `true`/`false` - Enable or disable SwaggerUI. If enabled, it will be available on `/swaggerui`. Disabled by default. Requires `PUSH_OPENAPI_EXPOSE_SPEC` to also be enabled.

##### Settings for FCM service:
* `PUSH_FCM_ENDPOINT` - Hostname of `FCM` service. Set only for local testing. By default this option points to the Google's official hostname
* `PUSH_FCM_APP_FILE` - Path to `FCM` service account JSON file. For details look at **Running from DockerHub** section
* `PUSH_FCM_POOL_SIZE` - Connection pool size for `FCM` service

##### Settings for development APNS service:
* `PUSH_APNS_DEV_ENDPOINT` - Hostname of `APNS` service. Set only for local testing. By default this option points to the Apple's official hostname
* `PUSH_APNS_DEV_CERT` - Path Apple's development certfile used to communicate with `APNS`
* `PUSH_APNS_DEV_KEY` - Path Apple's development keyfile used to communicate with `APNS`
* `PUSH_APNS_DEV_KEY_ID` - Key ID generated from Apple's developer console. For details look at **Running from DockerHub** section *required for token authentication*
* `PUSH_APNS_DEV_TEAM_ID` - TEAM ID generated from Apple's developer console. For details look at **Running from DockerHub** section *required for token authenticaton*
* `PUSH_APNS_DEV_P8_TOKEN` - Token generated from Apple's developer console. For details look at **Running from DockerHub** section
* `PUSH_APNS_DEV_USE_2197` - `true`/`false` - Enable or disable use of alternative `2197` port for `APNS` connections in development mode. Disabled by default
* `PUSH_APNS_DEV_POOL_SIZE` - Connection pool size for `APNS` service in development mode
* `PUSH_APNS_DEV_DEFAULT_TOPIC` - Default `APNS` topic to be set if the client app doesn't specify it with the API call. If this option is not set, MongoosePush will try to extract this value from the provided APNS certificate (the first topic will be assumed default). DEV certificates normally don't provide any topics, so this option can be safely left unset

##### Settings for production APNS service:
* `PUSH_APNS_PROD_ENDPOINT` - Hostname of `APNS` service. Set only for local testing. By default this option points to the Apple's official hostname
* `PUSH_APNS_PROD_CERT` - Path Apple's production certfile used to communicate with `APNS`
* `PUSH_APNS_PROD_KEY` - Path Apple's production keyfile used to communicate with `APNS`
* `PUSH_APNS_PROD_KEY_ID` - Key ID generated from Apple's developer console. For details look at **Running from DockerHub** section *required for token authentication*
* `PUSH_APNS_PROD_TEAM_ID` - TEAM ID generated from Apple's developer console. For details look at **Running from DockerHub** section *required for token authenticaton*
* `PUSH_APNS_PROD_P8_TOKEN` - Token generated from Apple's developer console. For details look at **Running from DockerHub** section
* `PUSH_APNS_PROD_USE_2197` - `true`/`false` - Enable or disable use of alternative `2197` port for `APNS` connections in production mode. Disabled by default
* `PUSH_APNS_PROD_POOL_SIZE` - Connection pool size for `APNS` service in production mode
* `PUSH_APNS_PROD_DEFAULT_TOPIC` - Default `APNS` topic to be set if the client app doesn't specify it with the API call. If this option is not set, MongoosePush will try to extract this value from the provided APNS certificate (the first topic will be assumed default)

#### Configuration (advanced)

Alternatively, the configuration can be done with a TOML configuration file. The file has to be present within the MongoosePush release as `var/config.toml`. In the Docker Container, this means you need to mount this file under: `/opt/app/var/config.toml`. Whenever this file is present, the "basic" configuration based on environmental variables is mostly disregarded. Some options may fall back to env variables when the default is needed - if so, this is gonna be explicitly stated in field description. Most importantly, whenever you use TOML configuration, the entire FCM/APNS service configuration has to be made with TOML - environmental variables will be completely disregarded, as this replaces all pool definitions.
Using a TOML configuration file enables some features that are hard to represent with environmental variables. Most notable example of that is having multiple connection pools per service, with different auth methods/files.

##### TOML schema

###### General keys

* `general.logging.level` (*string*, *optional*) - One of: `debug`/`info`/`warn`/`error`. If not set, falls back to the environmental variable `PUSH_LOGLEVEL` or its default.
* `general.https.bind.addr` (*string*, *optional*) - Bind IP address of the HTTPS endpoint. If not set, falls back to the environmental variable `PUSH_HTTPS_BIND_ADDR` or its default.
* `general.https.bind.port` (*integer*, *optional*) - Port of the HTTPS endpoint. If not set, falls back to the environmental variable `PUSH_HTTPS_PORT` or its default.
* `general.https.num_acceptors` (*integer*, *optional*) - Number of TCP acceptors to start. If not set, falls back to the environmental variable `PUSH_HTTPS_ACCEPTORS` or its default.
* `general.https.certfile` (*string*, *optional*) - Path to a PEM certfile used for HTTPS endpoint. If not set, falls back to the environmental variable `PUSH_HTTPS_CERTFILE` or its default. See `PUSH_HTTPS_CERTFILE` documentation for more details.
* `general.https.keyfile` (*string*, *optional*) - Path to a PEM keyfile used for HTTPS endpoint. If not set, falls back to the environmental variable `PUSH_HTTPS_KEYFILE` or its default. See `PUSH_HTTPS_KEYFILE` documentation for more details.
* `general.https.cacertfile` (*string*, *optional*) - Path to a PEM cacertfile used for HTTPS endpoint. If not set, falls back to the environmental variable `PUSH_HTTPS_CERTFILE` or its default. See `PUSH_HTTPS_CERTFILE` documentation for more details.
* `general.openapi.expose_spec` (*boolean*, *optional*) - Enable or disable OpenAPI specification endpoint. If enabled, it will be available on `/swagger.json` HTTP path. If not set, falls back to the environmental variable `PUSH_OPENAPI_EXPOSE_SPEC` or its default.
* `general.openapi.expose_ui` (*boolean*, *optional*) - Enable or disable SwaggerUI. If enabled, it will be available on `/swaggerui` HTTP path.  If not set, falls back to the environmental variable `PUSH_OPENAPI_EXPOSE_UI` or its default.

###### FCM keys

`[[service.fcm]]` (*array*, *optional*) - TOML Array representing a single FCM connection pool. Can have its own connection details like auth, and can be defined with a unique set of `tags` that can be later used when sending notifications to find a proper connection pool. If no `service.fcm` array entry is provided, FCM will be disabled. All following TOML keys are valid for any `service.fcm` array entry:

* `service.fcm.tags` (*list(string)*, *optional*) - List of tags to identify this connection pool. When sending push notifications, you can provide a similar list of tags to "select" a correct connection pool. Notifications will be send only via a connection pool that defines all tags provided along with a notification request.
* `service.fcm.connection.endpoint` (*string*, *optional*) - Domain/Host of the FCM server. You should leave this not set to use official FCM servers.
* `service.fcm.connection.port` (*integer*, *optional*) - Port of the FCM server. You should leave this not set to use official FCM servers.
* `service.fcm.connection.count` (*integer*, *optional*) - Number of connections to open. Default is 5.
* `service.fcm.auth.appfile` (*string*, *optional*) - Path to the FCM "app file" from the FCM admin console. This path should be either absolute, or relative to root dir of the release (in Docker container that would be `/opt/app`). Default: `priv/fcm/token.json`.

###### APNS keys

`[[service.apns]]` (*array*, *optional*) - TOML Array representing a single APNS connection pool. Can have its own connection details like auth, and can be defined with a unique set of `tags` that can be later used when sending notifications to find a proper connection pool. If no `service.apns` array entry is provided, APNS will be disabled. All following TOML keys are valid for any `service.apns` array entry:

* `service.apns.tags` (*list(string)*, *optional*) - List of tags to identify this connection pool. When sending push notifications, you can provide a similar list of tags to "select" a correct connection pool. Notifications will be send only via a connection pool that defines all tags provided along with the notification request.
* `service.apns.connection.endpoint` (*string*, *optional*) - Domain/Host of APNS server. You should leave this not set to use official APNS servers.
* `service.apns.connection.use_2197` (*boolean*, *optional*) - Port of APNS server (2197 or default). You should leave this not set to use official APNS servers.
* `service.apns.connection.count` (*integer*, *optional*) - Number of connections to open. Default is 5.

If token authentication is to be used:

* `service.apns.auth.token.key_id` (*string*, *required*) - "Key ID" for this APNS token. See APNS documentation for more details.
* `service.apns.auth.token.team_id` (*string*, *required*) - "Team ID" for this APNS token. See APNS documentation for more details.
* `service.apns.auth.token.tokenfile` (*string*, *required*) - Path to this APNS token P8 file. This path should be either absolute, or relative to root dir of the release (in Docker container that would be `/opt/app`).

If the certificate authentication is to be used:

* `service.apns.auth.certificate.keyfile` (*string*, *required*) - Path to the PEM encoded keyfile. This path should be either absolute, or relative to root dir of the release (in the Docker container that would be `/opt/app`).
* `service.apns.auth.certificate.certfile` (*string*, *required*) - Path to the PEM encoded certfile. This path should be either absolute, or relative to root dir of the release (in the Docker container that would be `/opt/app`).

Please note that only one method of authentication can be used for any given pool. This means that setting `service.apns.auth.certificate` excludes `service.apns.auth.token` and vice versa. Providing both will result in a configuration error.


###### Example configuration

```toml
[general]
  [general.logging]
    level = "info"
  [general.https]
    bind = { addr = "0.0.0.0", port = 8443 }
    num_acceptors = 100
    certfile = "priv/ssl/fake_cert.pem"
    keyfile = "priv/ssl/fake_key.pem"
    cacertfile = "priv/ssl/fake_cert.pem"
  [general.openapi]
    expose_spec = true
    expose_ui = false

[[service.fcm]]
  tags = ["tag1", "tag2"]
  [service.fcm.connection]
    endpoint = "localhost"
    port = 443
    count = 10
  [service.fcm.auth]
    appfile = "priv/fcm/token.json"

[[service.fcm]]
  tags = ["another1", "another2"]
  [service.fcm.connection]
    endpoint = "localhost"
    port = 443
    count = 10
  [service.fcm.auth]
    appfile = "priv/fcm/token.json"

[[service.apns]]
  mode = "dev"
  default_topic = "some.topic"
  tags = ["tag1", "tag2"]
  [service.apns.connection]
    endpoint = "localhost"
    use_2197 = true
    count = 10
  [service.apns.auth.token]
    key_id = "some id"
    team_id = "my team"
    tokenfile = "priv/apns/token.p8"


[[service.apns]]
  mode = "prod"
  default_topic = "some.topic"
  tags = ["tag1", "tag2"]
  [service.apns.connection]
    endpoint = "localhost"
    use_2197 = false
    count = 10
  [service.apns.auth.certificate]
    keyfile = "priv/apns/dev_key.pem"
    certfile = "priv/apns/dev_cert.pem"
```

### Local build

#### Perquisites

* Elixir 1.5+ (http://elixir-lang.org/install.html)
* Erlang/OTP 19.3+
  > NOTE: Some Erlang/OTP 20.x releases / builds contain TLS bug that prevents connecting to APNS servers.
  > When building with this Erlang version, please make sure that MongoosePushRuntimeTest test suite passes.
  > It is however highly recommended to build MongoosePush with Erlang/OTP 21.x.
* Rebar3 (just enter ```mix local.rebar```)

#### Build and run of production release

Build step is really easy. Just type in root of the repository:
```bash
MIX_ENV=prod mix do deps.get, compile, certs.dev, distillery.release
```

After this step you may try to run the service via:
```bash
_build/prod/rel/mongoose_push/bin/mongoose_push foreground
```

Yeah, I know... It crashed. Running this service is fast and simple but unfortunately you can't have push notifications without properly configured `FCM` and/or `APNS` service. You can find out how to properly configure it in `Configuration` section of this README.

#### Build and run of development release

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


### Running tests

One thing that you need to do *once* before running any tests is generating fake certificates for APNS/HTTPS (it doesn't matter which MIX_ENV you run this in):

```bash
mix certs.dev
```

Also, you'll need to have `docker-compose` installed and present in path to run any tests.

#### TL;DR

```bash
# Unit tests
MIX_ENV=test mix do test.env.up, test, test.env.down

# Integration tests
MIX_ENV=integration mix do test.env.up, test, test.env.down
```

#### Basic tests (non-release)

Basic tests require FCM and APNS mock services to be present at the time of running the tests:

```bash
# We start the mocks
mix test.env.up

# Now we can just run tests
mix test

# Optionally we can shut the mocks down. If you want to rerun the tests, you may skip this step do that
# you don't need to re-invoke `mix test.env.up`. Mocks are being reset by each test separately,
# so you don't need to worry about their state.
mix test.env.down
```

#### Integration tests (using production-grade release)

Integration tests can be run in exactly the same way as described above for "basic" tests, with one exception:
All Mix commands need to be invoked in `MIX_ENV=integration` environment:

```bash
# We start the mocks AND MongoosePush docker container.
# This may take a few minutes on the first run, as the MongoosePush docker image needs
# to build from scratch. Subsequent runs should be much faster.
# You need to call each time you make changes in the app code, as MongoosePush
# needs to be rebuilt and redeployed!
MIX_ENV=integration mix test.env.up

# Now we can just run tests
MIX_ENV=integration mix test

# Optionally we can shut the mocks down. If you want to rerun tests, you may skip this step do that
# you don't need to re-invoke `mix test.env.up`. Mocks are being reset by each test separately,
# so you don't need to worry about their state.
MIX_ENV=integration mix test.env.down
```

**NOTE**:
You need to call `MIX_ENV=integration mix test.env.up` each time you make changes in the app code, as MongoosePush needs to be built and redeployed before running integrations tests!

#### Details on `mix test.env.*` commands

* `mix test.env.up` - runs `docker-compose up -d --build` with the following compose files:
  * for `MIX_ENV=test` and `MIX_ENV=dev`: *test/docker/docker-compose.mocks.yml*
  * for `MIX_ENV=integration`: *test/docker/docker-compose.mocks.yml* and *test/docker/docker-compose.mpush.yml*
* `mix test.env.down` - runs `docker-compose down` on the same compose files as `mix test.env.up`
* `mix test.env.wait X` - waits up to X milliseconds for the services from `mix test.env.up` to become available. Prints error if they don't.

## Configuration

The whole configuration is contained in file `config/{prod|dev|test}.exs` depending on which `MIX_ENV` you will be using. You should use `MIX_ENV=prod` for production installations and `MIX_ENV=dev` for your development. Anyway, lets take a look on `config/dev.exs`, part by part.

### RESTful API configuration

```elixir
config :mongoose_push, MongoosePushWeb.Endpoint,
  https: [
    ip: {127, 0, 0, 1},
    port: 8443,
    keyfile: "priv/ssl/fake_key.pem",
    certfile: "priv/ssl/fake_cert.pem",
    otp_app: :mongoose_push
  ]
```
This part of configuration relates only to `HTTPS` endpoints exposed by `MongoosePush`. Here you can set a bind IP adress (option: `ip`), port and paths to your `HTTPS` `TLS` certificates. You should ignore other options unless you know what you're doing (to learn more, explore [phoenix documentation](https://hexdocs.pm/phoenix/overview.html)).

You may entirely skip the `mongoose_push` config entry to disable `HTTPS` API and just use this project as an `Elixir` library.

### FCM configuration
Let's take a look at sample `FCM` service configuration:
```elixir
config :mongoose_push, fcm: [
    default: [
        appfile: "path/to/token.json",
        endpoint: "localhost",
        pool_size: 5,
        mode: :prod,
        tls_opts: []
    ]
  ]
```

This is a definition of a pool - each pool has a name and configuration. It is possible to have multiple named pools with different configuration, which includes pool size, environment mode etc. Currently the only reason you may want to do this is to create separate production and development pools which may be selected by an `HTTP` client by specifying matching `:mode` in their push request.

Each `FCM` pool may be configured by setting the following fields:
* **appfile** (*required*) - path to `FCM` service account JSON file. Details on how to get one are in **Running from DockerHub** section
* **pool_size** (*required*) - maximum number of used `HTTP/2` connections to google's service
* **mode** (*either `:prod` or `:dev`*) - pool's mode. The `HTTP` client may select pool used to push a notification by specifying matching option in the request
* **endpoint** (*optional*) - URL override for `FCM` service. Useful mainly in tests
* **port** (*optional*) - Port number override for `FCM` service. Useful mainly in tests
* **tags** (*optional*) - a list of tags. Used when choosing pool to match request tags when sending a notification. More details: https://github.com/esl/sparrow#tags
* **tls_opts** (*optional*) - a list of raw options passed to `ssl:connect` function call while connecting to `FCM`. When this option is omitted, it will default to set of values that will verify server certificate based on internal CA chain. Providing this option overrides all defaults, effectively disabling certificate validation. Therefore passing this option is not recommended outside dev and test environments.

You may entirely skip the `FCM` config entry to disable `FCM` support.

### APNS configuration

Lets take a look at sample `APNS` service configuration:
```elixir
config :mongoose_push, apns: [
   dev: [
     cert: "priv/apns/dev_cert.pem",
     key: "priv/apns/dev_key.pem",
     mode: :dev,
     use_2197: false,
     pool_size: 5,
     tls_opts: []
   ],
   prod: [
     cert: "priv/apns/prod_cert.pem",
     key: "priv/apns/prod_key.pem",
     mode: :prod,
     use_2197: false,
     pool_size: 5,
     tls_opts: []
   ]
 ]
 ```
Just like for `FCM`, at the top level we can specify the named pools that have different configurations. For `APNS` this is especially useful since Apple delivers different APS certificates for development and production use. The HTTP client can select a named pool by providing a matching :mode in the HTTP request.

Each `APNS` pool may be configured by setting the following fields:
* **cert** (*required*) - relative path to `APNS` `PEM` certificate issued by Apple. This certificate have to be somewhere in `priv` directory
* **key** (*required*) - relative path to `PEM` private key for `APNS` certificate issued by Apple. This file have to be somewhere in `priv` directory
* **pool_size** (*required*) - maximum number of used `HTTP/2` connections to google's service
* **mode** (*either `:prod` or `:dev`*) - pool's mode. The `HTTP` client may select pool used to push a notification by specifying matching option in the request
* **endpoint** (*optional*) - URL override for `APNS` service. Useful mainly in tests
* **port** (*optional*) - Port number override for `APNS` service. Useful mainly in tests
* **use_2197** (*optional `true` or `false`*) - whether use alternative port for `APNS`: 2197
* **tags** (*optional*) - a list of tags. Used when choosing pool to match request tags when sending a notification. More details: https://github.com/esl/sparrow#tags
* **tls_opts** (*optional*) - a list of raw options passed to `ssl:connect` function call while connecting to `APNS`. When this option is omitted, it will default to set of values that will verify server certificate based on internal CA chain. Providing this option overrides all defaults, effectively disabling certificate validation. Therefore passing this option is not recommended outside dev and test environments.

You may entirely skip the `APNS` config entry to disable `APNS` support.

#### Converting APNS files

If you happen to have APNS files in `pkcs12` format (.p12 or .pfx extenstion) you need to convert them to `PEM` format which is understood by MongoosePush. Belowe you can find sample `openssl` commands which may be helpful.

##### Get cert from pkcs12 file

    openssl pkcs12 -in YourAPNS.p12 -out YourCERT.pem -nodes -nokeys

#### Get key from pkcs12 file

    openssl pkcs12 -in YourAPNS.p12 -out YourKEY.pem -nodes -nocerts



## RESTful API

### Swagger

If for some reason you need `Swagger` spec for this `RESTful` service, there is a swagger endpoint available via an `HTTP` path `/swagger.json`

### Just tell me what to send already

#### Request

There is only one endpoint at this moment:
* `POST /{version}/notification/{device_id}`

As you can imagine, `{device_id}` should be replaced with device ID/Token generated by your push notification provider (`FCM` or `APNS`). The notification should be sent as `JSON` payload of this request. Minimal `JSON` request could be like this:

```json
{
  "service": "apns",
  "alert":
    {
      "body": "notification's text body",
      "title": "notification's title"
    }
}
```

The full list of options contains the following:
* **service** (*required*, `apns` or `fcm`) - push notifications provider to be used for this notification
* **mode** (*optional*, `prod` (default) or `dev`) - allows for selecting named pool configured in `MongoosePush`
* **priority** (*optional*) - Either `normal` or `high`. Those values are used without changes for FCM. For APNS however, `normal` maps to priority `5`, while `high` maps to priority `10`. Please refer to FCM / APNS documentation for more details on those values. By default `priority` is not set at all, therefore the push notification service decides which value is used by default.
* **time_to_live** (*optional*) - Maximum lifespan of an FCM notification. For more details, please, refer to [the official FCM documentation](https://firebase.google.com/docs/cloud-messaging/concept-options#ttl).
* **mutable_content** (*optional*, `true` / `false` (default)) - Only applicable to APNS. Sets "mutable-content=1" in APNS payload.
* **topic** (*optional*, `APNS` specific) - if APNS certificate configured in `MongoosePush` allows for multiple applications, this field selects the application. Please refer to `APNS` documentation for more datails
* **tags** (*optional*) - a list of tags used to choose a pool with matching tags. To see how tags work read: https://github.com/esl/sparrow#tags
* **data** (*optional*) - custom JSON structure sent to the target device. For `APNS`, all keys form this stucture are merged into highest level APS message (the one that holds 'aps' key), while for `FCM` the whole `data` json stucture is sent as FCM's `data payload` along with `notification`.
* **alert** (*optional*) - JSON stucture that if provided will send non-silent notification with the following fields:
  * **body** (*required*) - text body of notification
  * **title** (*required*) - short title of notification
  * **click_action** (*optional*) - for `FCM` its `activity` to run when notification is clicked. For `APNS` its `category` to invoke. Please refer to Android/iOS documentation for more details about this action
  * **tag** (*optional*, `FCM` specific) - notifications aggregation key
  * **badge** (*optional*, `APNS` specific) - unread notifications count
  * **sound** (*optional*) - sound that should be play when notification arrives. Please refer to FCM / APNS documentation for more details.

Please note that either **alert** and **data** has to be provided (also can be both).
If you only specify **alert**, the request will result in classic, simple notification.
If you only specify **data**, the request will result in "silent" notification, i.e. the client will receive the data and will be able to decide whether notification shall be shown and how should be shown to the user.
If you specify both **alert** and **data**, target device will receive both notification and the custom data payload to process.

#### Description of the possible server responses

* **200** `"OK"` - the request was successful.
* **400** `{"reason" : "invalid_request"|"no_matching_pool"}` - the request was invalid.
* **410** `{"reason" : "unregistered"}` - the device was not registered.
* **413** `{"reason" : "payload_too_large"}` - the payload was too large.
* **429** `{"reason" : "too_many_requests"}` - there were too many requests to the server.
* **503** `{"reason" : "service_internal"|"internal_config"|"unspecified"}` - the internal service or configuration error occured.
* **520** `{"reason" : "unspecified"}` - the unknown error occured.
* **500** `{"reason" : reason}` - the server internal error occured,
  specified by **reason**.

### Metrics

MongoosePush 2.1 provides metrics in the Prometheus format on the `/metrics` endpoint.
This is a breaking change compared to previous releases.
Existing dashboards will need to be updated.

It is important to know that metrics are created inside MongoosePush only when a certain event happens.
This may mean that a freshly started MongoosePush node will not have all the possible metrics available yet.

#### Available metrics

##### Histograms

For more details about the histogram metric type please go to https://prometheus.io/docs/concepts/metric_types/#histogram

###### Notification sent time

`mongoose_push_notification_send_time_microsecond_bucket{error_category=${CATEGORY},error_reason=${REASON},service=${SERVICE},status=${STATUS},le=${LE}}`
`mongoose_push_notification_send_time_microsecond_sum{error_category=${CATEGORY},error_reason=${REASON},service=${SERVICE},status=${STATUS}}`
`mongoose_push_notification_send_time_microsecond_count{error_category=${CATEGORY},error_reason=${REASON},service=${SERVICE},status=${STATUS}}`

Where:
* `STATUS` is `"success"` for the successful notifications or `"error"` in all other cases
* `SERVICE` is either `"apns"` or `"fcm"`
* `CATEGORY` is an arbitrary error category term (in case of `status="error"`) or an empty string (when `status="success"`)
* `REASON` is an arbitrary error reason term (in case of `status="error"`) or an empty string (when `status="success"`)
* `LE` defines the `upper inclusive bound` (`less than or equal`) values for buckets, currently `1000`, `10_000`, `25_000`, `50_000`, `100_000`, `250_000`, `500_000`, `1000_000` or `+Inf`

This histogram metric shows the distribution of times needed to:
1. Select a worker (this may include waiting time when all workers are busy).
2. Send a request.
3. Get a response from push notifications provider.

###### HTTP/2 requests

`sparrow_h_worker_handle_duration_microsecond_bucket{le=${LE}}`
`sparrow_h_worker_handle_duration_microsecond_sum{le=${LE}}`
`sparrow_h_worker_handle_duration_microsecond_count{le=${LE}}`

Where:
* `LE` defines the `upper inclusive bound` (`less than or equal`) values for buckets, currently `1000`, `10_000`, `25_000`, `50_000`, `100_000`, `250_000`, `500_000`, `1000_000` or `+Inf`

> **NOTE**
>
> A bucket of value 250_000 will keep the count of measurements that are less than or equal to 250_000.
> A measurement of value 51_836 will be added to all the buckets where the upper bound is greater than 51_836.
> In this case these are buckets `100_000`, `250_000`, `500_000`, `1000_000` and `+Inf`

##### Counters

* `mongoose_push_supervisor_init_count{service=${SERVICE}}` - Counts the number of push notification service supervisor starts.
  The `SERVICE` variable can take `"apns"` or `"fcm"` as a value.
  This metric is updated when MongoosePush starts, and later on when the underlying supervision tree is terminated and the error is propagated to the main application supervisor.
* `mongoose_push_apns_state_init_count` - Counts the number of APNS state initialisations.
* `mongoose_push_apns_state_terminate_count` - Counts the number of APNS state terminations.
* `mongoose_push_apns_state_get_default_topic_count` - Counts the number of default topic reads from cache.
* `sparrow_pools_warden_pools_count` - Counts the number of worker pools.
* `sparrow_pools_warden_workers_count{pool=${POOL}}` - Counts the number of workers operated by a given worker `POOL`.

#### How to quickly see all metrics

```bash
curl -k https://127.0.0.1:8443/metrics
```

The above command assumes that MongoosePush runs on `localhost` and listens on port `8443`.
Please, mind the `HTTPS` protocol, metrics are hosted on the same port than all the other API endpoints.

#### Prometheus configuration

When configuring Prometheus, it's important to:
* set the `scheme` to `https` since MongoosePush exposes `/metrics` path encrypted endpoint (HTTPS)
* set the `insecure_skip_verify` to `true` if the default self-signed certificates are used

```yaml
scrape_configs:
  - job_name: 'mongoose-push'
    scheme: 'https' #MongoosePush exposes encrypted endpoint - HTTPS
    tls_config: #The default certs used by MongoosePush are self-signed
      insecure_skip_verify: true #For checking purposes we can ignore certs verification
    static_configs:
      - targets: ['mongoose-push:8443']
        labels:
          group: 'production'

```
