# Configuration

The whole configuration is contained in the `config/{prod|dev|test}.exs` file, depending on which `MIX_ENV` you will be using. You should use `MIX_ENV=prod` for production installations and `MIX_ENV=dev` for your development.

Let's examine `config/dev.exs`.

## RESTful API configuration

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
This part of the configuration relates only to the `HTTPS` endpoints exposed by `MongoosePush`. Here you can set an IP address (option: `ip`), a port, and paths to your `HTTPS` `TLS` certificates. You should ignore other options unless you are sure you know what you're doing (to learn more, explore [phoenix documentation](https://hexdocs.pm/phoenix/overview.html)).

You may entirely skip the `mongoose_push` config entry to disable the `HTTPS` API and just use this project as an `Elixir` library.

## FCM configuration
Let's take a look at a sample `FCM` service configuration:
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

This is a definition of a pool - each pool has a name and a configuration. It is possible to have multiple named pools with different configuration, which includes pool size, environment mode, etc. Currently the only reason you may want to do this is to create separate production and development pools which may be selected by an `HTTP` client by specifying matching `:mode` in their push request.

Each `FCM` pool may be configured by setting the following fields:
* **appfile** (*required*) - path to an `FCM` service account JSON file. Details on how to get one are in the [Running from DockerHub](docker.md#running-from-dockerhub) section
* **pool_size** (*required*) - maximum number of used `HTTP/2` connections to google's service
* **mode** (*either `:prod` or `:dev`*) - pool's mode. The `HTTP` client may select a pool used to push a notification by specifying a matching option in the request
* **endpoint** (*optional*) - URL override for the `FCM` service. Useful mainly in tests
* **port** (*optional*) - Port number override for `the FCM` service. Useful mainly in tests
* **tags** (*optional*) - a list of tags. Used when choosing a pool to match the request tags when sending a notification. More details: https://github.com/esl/sparrow#tags
* **tls_opts** (*optional*) - a list of raw options passed to the `ssl:connect` function call while connecting to `FCM`. When this option is omitted, it will default to a set of values that will verify the server certificate based on an internal CA chain. Providing this option overrides all defaults, effectively disabling certificate validation. Therefore passing this option is not recommended outside dev and test environments.

You may entirely skip the `FCM` config entry to disable `FCM` support.

## APNS configuration

Lets take a look at a sample `APNS` service configuration:
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
* **cert** (*required*) - relative path to `APNS` `PEM` certificate issued by Apple. This certificate has to be somewhere in the `priv` directory
* **key** (*required*) - relative path to `PEM` private key for `APNS` certificate issued by Apple. This file has to be somewhere in the `priv` directory
* **pool_size** (*required*) - maximum number of used `HTTP/2` connections to the google's service
* **mode** (*either `:prod` or `:dev`*) - pool's mode. The `HTTP` client may select a pool used to push a notification by specifying the matching option in the request
* **endpoint** (*optional*) - URL override for `APNS` service. Useful mainly in tests
* **port** (*optional*) - Port number override for `APNS` service. Useful mainly in tests
* **use_2197** (*optional `true` or `false`*) - whether to use an alternative port for `APNS`: 2197
* **tags** (*optional*) - a list of tags. Used when choosing a pool to match the request tags when sending a notification. More details: https://github.com/esl/sparrow#tags
* **tls_opts** (*optional*) - a list of raw options passed to the `ssl:connect` function call while connecting to `APNS`. When this option is omitted, it will default to a set of values that will verify the server certificate based on an internal CA chain. Providing this option overrides all defaults, effectively disabling certificate validation. Therefore passing this option is not recommended outside dev and test environments.

You may entirely skip the `APNS` config entry to disable `APNS` support.

#### Converting APNS files

If you happen to have APNS files in a `pkcs12` format (.p12 or .pfx extension) you need to convert them to the `PEM` format which is understood by MongoosePush. Below you can find sample `openssl` commands which may be helpful.

##### Get cert from pkcs12 file

    openssl pkcs12 -in YourAPNS.p12 -out YourCERT.pem -nodes -nokeys

#### Get key from pkcs12 file

    openssl pkcs12 -in YourAPNS.p12 -out YourKEY.pem -nodes -nocerts



## Environment variables

Environment variables to configure a production release.

#### Settings for HTTP endpoint:
* `PUSH_HTTPS_BIND_ADDR` - Bind IP address of the HTTP endpoint. Default value in prod release is "127.0.0.1", but docker overrides this with "0.0.0.0"
* `PUSH_HTTPS_PORT` - The port of the MongoosePush HTTP endpoint. Please note that docker exposes only `8443` port, so changing this setting is not recommended
* `PUSH_HTTPS_KEYFILE` - Path to a PEM keyfile used for HTTP endpoint. This path should be either absolute or relative to root of the release (in the Docker container that's `/opt/app`). Default: `priv/ssl/fake_key.pem`.
* `PUSH_HTTPS_CERTFILE` - Path to a PEM certfile used for HTTP endpoint. This path should be either absolute or relative to root of the release (in the Docker container that's `/opt/app`). Default: `priv/ssl/fake_cert.pem`.
* `PUSH_HTTPS_ACCEPTORS` - Number of TCP acceptors to start

#### General settings:
* `PUSH_LOGLEVEL` - `debug`/`info`/`warning`/`error` - Log level of the application. `info` is the default one
* `PUSH_LOGFORMAT` - `logfmt`/`json` - Log format of the application. Defaults to `logfmt` for the `dev` and `test` environments, and to `json` for the `prod` environment.
* `PUSH_FCM_ENABLED` - `true`/`false` - Enable or disable `FCM` support. Disabled by default
* `PUSH_APNS_ENABLED` - `true`/`false` - Enable or disable `APNS` support. Disabled by default
* `TLS_SERVER_CERT_VALIDATION` - `true`/`false` - Enable or disable TLS
  options for both FCM and APNS.
* `PUSH_OPENAPI_EXPOSE_SPEC` - `true`/`false` - Enable or disable OpenAPI specification endpoint support. If enabled, it will be available on `/swagger.json` HTTP path. Disabled by default
* `PUSH_OPENAPI_EXPOSE_UI` - `true`/`false` - Enable or disable SwaggerUI. If enabled, it will be available on `/swaggerui`. Disabled by default. Requires `PUSH_OPENAPI_EXPOSE_SPEC` to also be enabled.

#### Settings for FCM service:
* `PUSH_FCM_ENDPOINT` - Hostname of the `FCM` service. Set only for local testing. By default this option points to the Google's official hostname
* `PUSH_FCM_APP_FILE` - Path to the `FCM` service account JSON file. For details look at [Running from DockerHub](docker.md#running-from-dockerhub) section
* `PUSH_FCM_POOL_SIZE` - Connection pool size for the `FCM` service

#### Settings for development APNS service:
* `PUSH_APNS_DEV_ENDPOINT` - Hostname of the `APNS` service. Set only for local testing. By default this option points to the Apple's official hostname
* `PUSH_APNS_DEV_CERT` - Path to Apple's development certfile used to communicate with `APNS`
* `PUSH_APNS_DEV_KEY` - Path to Apple's development keyfile used to communicate with `APNS`
* `PUSH_APNS_DEV_KEY_ID` - Key ID generated from Apple's developer console. For details look at the [Running from DockerHub](docker.md#running-from-dockerhub) section *required for token authentication*
* `PUSH_APNS_DEV_TEAM_ID` - TEAM ID generated from Apple's developer console. For details look at the [Running from DockerHub](docker.md#running-from-dockerhub) section *required for token authenticaton*
* `PUSH_APNS_DEV_P8_TOKEN` - Token generated from Apple's developer console. For details look at the [Running from DockerHub](docker.md#running-from-dockerhub) section
* `PUSH_APNS_DEV_USE_2197` - `true`/`false` - Enable or disable the use of an alternative `2197` port for `APNS` connections in development mode. Disabled by default
* `PUSH_APNS_DEV_POOL_SIZE` - Connection pool size for `APNS` service in development mode
* `PUSH_APNS_DEV_DEFAULT_TOPIC` - Default `APNS` topic to be set if the client app doesn't specify it with the API call. If this option is not set, MongoosePush will try to extract this value from the provided APNS certificate (the first topic will be assumed default). DEV certificates normally don't provide any topics, so this option can be safely left unset

#### Settings for production APNS service:
* `PUSH_APNS_PROD_ENDPOINT` - Hostname of the `APNS` service. Set only for local testing. By default this option points to the Apple's official hostname
* `PUSH_APNS_PROD_CERT` - Path to Apple's production certfile used to communicate with `APNS`
* `PUSH_APNS_PROD_KEY` - Path to Apple's production keyfile used to communicate with `APNS`
* `PUSH_APNS_PROD_KEY_ID` - Key ID generated from Apple's developer console. For details look at the [Running from DockerHub](docker.md#running-from-dockerhub) section *required for token authentication*
* `PUSH_APNS_PROD_TEAM_ID` - TEAM ID generated from Apple's developer console. For details look at the  [Running from DockerHub](docker.md#running-from-dockerhub) section *required for token authenticaton*
* `PUSH_APNS_PROD_P8_TOKEN` - Token generated from Apple's developer console. For details look at the [Running from DockerHub](docker.md#running-from-dockerhub) section
* `PUSH_APNS_PROD_USE_2197` - `true`/`false` - Enable or disable the use of an alternative `2197` port for `APNS` connections in production mode. Disabled by default
* `PUSH_APNS_PROD_POOL_SIZE` - Connection pool size for `APNS` service in production mode
* `PUSH_APNS_PROD_DEFAULT_TOPIC` - Default `APNS` topic to be set if the client app doesn't specify it with the API call. If this option is not set, MongoosePush will try to extract this value from the provided APNS certificate (the first topic will be assumed default)

## TOML schema

  > IMPORTANT:
  > When a configuration option is defined in TOML file it can't be overwritten by environmental variables.
  > You can use both methods for different options though. 

#### General keys

* `general.logging.level` (*string*, *optional*) - One of: `debug`/`info`/`warning`/`error`. If not set, falls back to the environment variable `PUSH_LOGLEVEL` or its default.
* `general.https.bind.addr` (*string*, *optional*) - Bind IP address of the HTTPS endpoint. If not set, falls back to the environment variable `PUSH_HTTPS_BIND_ADDR` or its default.
* `general.https.bind.port` (*integer*, *optional*) - Port of the HTTPS endpoint. If not set, falls back to the environment variable `PUSH_HTTPS_PORT` or its default.
* `general.https.num_acceptors` (*integer*, *optional*) - Number of TCP acceptors to start. If not set, falls back to the environment variable `PUSH_HTTPS_ACCEPTORS` or its default.
* `general.https.certfile` (*string*, *optional*) - Path to a PEM certfile used for HTTPS endpoint. If not set, falls back to the environment variable `PUSH_HTTPS_CERTFILE` or its default. See `PUSH_HTTPS_CERTFILE` documentation for more details.
* `general.https.keyfile` (*string*, *optional*) - Path to a PEM keyfile used for HTTPS endpoint. If not set, falls back to the environment variable `PUSH_HTTPS_KEYFILE` or its default. See `PUSH_HTTPS_KEYFILE` documentation for more details.
* `general.https.cacertfile` (*string*, *optional*) - Path to a PEM cacertfile used for HTTPS endpoint. If not set, falls back to the environment variable `PUSH_HTTPS_CERTFILE` or its default. See `PUSH_HTTPS_CERTFILE` documentation for more details.
* `general.openapi.expose_spec` (*boolean*, *optional*) - Enable or disable OpenAPI specification endpoint. If enabled, it will be available on `/swagger.json` HTTP path. If not set, falls back to the environment variable `PUSH_OPENAPI_EXPOSE_SPEC` or its default.
* `general.openapi.expose_ui` (*boolean*, *optional*) - Enable or disable SwaggerUI. If enabled, it will be available on `/swaggerui` HTTP path.  If not set, falls back to the environment variable `PUSH_OPENAPI_EXPOSE_UI` or its default.

#### FCM keys

`[[service.fcm]]` (*array*, *optional*) - TOML Array representing a single FCM connection pool. Can have its own connection details like auth, and can be defined with a unique set of `tags` that can be later used when sending notifications to find a proper connection pool. If no `service.fcm` array entry is provided, FCM will be disabled. All following TOML keys are valid for any `service.fcm` array entry:

* `service.fcm.tags` (*list(string)*, *optional*) - List of tags to identify this connection pool. When sending push notifications, you can provide a similar list of tags to "select" a correct connection pool. Notifications will be send only via a connection pool that defines all tags provided along with a notification request.
* `service.fcm.connection.endpoint` (*string*, *optional*) - Domain/Host of the FCM server. You should leave this not set to use official FCM servers.
* `service.fcm.connection.port` (*integer*, *optional*) - Port of the FCM server. You should leave this not set to use official FCM servers.
* `service.fcm.connection.count` (*integer*, *optional*) - Number of connections to open. Default is 5.
* `service.fcm.auth.appfile` (*string*, *optional*) - Path to the FCM "app file" from the FCM admin console. This path should be either absolute, or relative to root dir of the release (in Docker container that would be `/opt/app`). Default: `priv/fcm/token.json`.

#### APNS keys

`[[service.apns]]` (*array*, *optional*) - TOML Array representing a single APNS connection pool. Can have its own connection details like auth, and can be defined with a unique set of `tags` that can be later used when sending notifications to find a proper connection pool. If no `service.apns` array entry is provided, APNS will be disabled. All following TOML keys are valid for any `service.apns` array entry:

* `service.apns.tags` (*list(string)*, *optional*) - List of tags to identify this connection pool. When sending push notifications, you can provide a similar list of tags to "select" a correct connection pool. Notifications will be send only via a connection pool that defines all tags provided along with the notification request.
* `service.apns.connection.endpoint` (*string*, *optional*) - Domain/Host of APNS server. You should leave this not set to use the official APNS servers.
* `service.apns.connection.use_2197` (*boolean*, *optional*) - Port of APNS server (2197 or default). You should leave this not set to use the official APNS servers.
* `service.apns.connection.count` (*integer*, *optional*) - Number of connections to open. Default is 5.

If token authentication is to be used:

* `service.apns.auth.token.key_id` (*string*, *required*) - "Key ID" for this APNS token. See APNS documentation for more details.
* `service.apns.auth.token.team_id` (*string*, *required*) - "Team ID" for this APNS token. See APNS documentation for more details.
* `service.apns.auth.token.tokenfile` (*string*, *required*) - Path to this APNS token P8 file. This path should be either absolute, or relative to the root dir of the release (in the Docker container that would be `/opt/app`).

If the certificate authentication is to be used:

* `service.apns.auth.certificate.keyfile` (*string*, *required*) - Path to the PEM encoded keyfile. This path should be either absolute, or relative to root dir of the release (in the Docker container that would be `/opt/app`).
* `service.apns.auth.certificate.certfile` (*string*, *required*) - Path to the PEM encoded certfile. This path should be either absolute, or relative to root dir of the release (in the Docker container that would be `/opt/app`).

Please note that only one method of authentication can be used for any given pool. This means that setting `service.apns.auth.certificate` excludes `service.apns.auth.token` and vice versa. Providing both will result in a configuration error.


#### Example configuration

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
