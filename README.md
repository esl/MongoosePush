# MongoosePush

[![Build Status](https://travis-ci.org/esl/MongoosePush.svg?branch=master)](https://travis-ci.org/esl/MongoosePush) [![Coverage Status](https://coveralls.io/repos/github/esl/MongoosePush/badge.svg?branch=master)](https://coveralls.io/github/esl/MongoosePush?branch=master) [![Ebert](https://ebertapp.io/github/esl/MongoosePush.svg)](https://ebertapp.io/github/esl/MongoosePush)

**MongoosePush** is simple (seriously) **REST** service written in **Elixir** providing ability to **send push
notification** to `FCM` (Firebase Cloud Messaging) and/or
`APNS` (Apple Push Notification Service) via their `HTTP/2` API.

## Quick start

### Docker

#### Running from DockerHub

We provide already built MongoosePush images. If you just want to use it, then all you need is `docker`, `FCM` app token and/or `APNS` app certificates.
In case of certificates you need to setup the following directory structure:
* priv/
    * ssl/
      * rest_cert.pem - The REST endpoint certificate
      * rest_key.pem - private key for the REST endpoint certificate (has to be unencrypted)
    * apns/
      * prod_cert.pem - Production APNS app certificate
      * prod_key.pem - Production APNS app certificate's private key (has to be unencrypted)
      * dev_cert.pem - Development APNS app certificate
      * dev_key.pem - Development APNS app certificate's private key (has to be unencrypted)

Assuming that your `FCM` app token is "MY_FCM_SECRET_TOKEN" and you have the `priv` directory with all ceriticates in current directory, then you may start MongoosePush with the following command:

```bash
docker run -v `pwd`/priv:/opt/app/priv \
  -e PUSH_FCM_APP_KEY="MY_FCM_SECRET_TOKEN" \
  -e PUSH_HTTPS_CERTFILE="/opt/app/priv/ssl/rest_cert.pem" \
  -e PUSH_HTTPS_KEYFILE="/opt/app/priv/ssl/rest_key.pem" \
  -it --rm mongooseim/mongoose-push:latest
```

#### Building

Building docker is really easy, just type:

```bash
MIX_ENV=prod mix do docker.build, docker.release
```

As a result of this command you get access to `mongoose_push:release` docker image. You may run it by typing:

```bash
docker run -it --rm mongoose_push:release foreground
```

Docker image that you have just built, exposes the port `8443` for the REST API of
MongoosePush. Also there is a `VOLUME` for path */opt/app* where the whole MongoosePush release is stored. This volume will be handy for injecting `APNS` and REST API certificates.

#### Configuring

The docker image of MongoosePush contains common, basic configuration that is generated from `config/prod.exs`. All useful options may be overridden via system environmental variables. Below there's a full list of the variables you may set while running docker (via `docker -e` switch), but if there's something you feel, you need to change other then that, then you need to prepare your own `config/prod.exs` before image build.

Environmental variables to configure production release:
##### Settings for REST endpoint:
* `PUSH_HTTPS_BIND_ADDR` - Bind IP address of the REST endpoint. Default value in prod release is "127.0.0.1", but docker overrides this with "0.0.0.0"
* `PUSH_HTTPS_PORT` - The port of the MongoosePush REST endpoint. Please not that docker exposes only `8443` port, so changing this setting is not recommended
* `PUSH_HTTPS_KEYFILE` - Path to PEM keyfile used for REST endpoint
* `PUSH_HTTPS_CERTFILE` - Path to PEM certfile used for REST endpoint
* `PUSH_HTTPS_ACCEPTORS` - Number of TCP acceptors to start

##### General settings:
* `PUSH_LOGLEVEL` - `debug`/`info`/`warn`/`error` - Log level of the application. `info` is the default one
* `PUSH_FCM_ENABLED` - `true`/`false` - Enable or disable `FCM` support. Enabled by default
* `PUSH_APNS_ENABLED` - `true`/`false` - Enable or disable `APNS` support. Enabled by default

##### Settings for FCM service:
* `PUSH_FCM_ENDPOINT` - Hostname of `FCM` service. Set only for local testing. By default this option points to the Google's official hostname
* `PUSH_FCM_APP_KEY` - App key token to use with `FCM` service
* `PUSH_FCM_POOL_SIZE` - Connection pool size for `FCM` service

##### Settings for development APNS service:
* `PUSH_APNS_DEV_ENDPOINT` - Hostname of `APNS` service. Set only for local testing. By default this option points to the Apple's official hostname
* `PUSH_APNS_DEV_CERT` - Path Apple's development certfile used to communicate with `APNS`
* `PUSH_APNS_DEV_KEY` - Path Apple's development keyfile used to communicate with `APNS`
* `PUSH_APNS_DEV_USE_2197` - `true`/`false` - Enable or disable use of alternative `2197` port for `APNS` connections in development mode. Disabled by default
* `PUSH_APNS_DEV_POOL_SIZE` - Connection pool size for `APNS` service in development mode
* `PUSH_APNS_DEV_DEFAULT_TOPIC` - Default `APNS` topic to be set if the client app doesn't specify it with the API call. If this option is not set, MongoosePush will try to extract this value from the provided APNS certificate (the first topic will be assumed default). DEV certificates normally don't provide any topics, so this option can be safely left unset

##### Settings for production APNS service:
* `PUSH_APNS_PROD_ENDPOINT` - Hostname of `APNS` service. Set only for local testing. By default this option points to the Apple's official hostname
* `PUSH_APNS_PROD_CERT` - Path Apple's production certfile used to communicate with `APNS`
* `PUSH_APNS_PROD_KEY` - Path Apple's production keyfile used to communicate with `APNS`
* `PUSH_APNS_PROD_USE_2197` - `true`/`false` - Enable or disable use of alternative `2197` port for `APNS` connections in production mode. Disabled by default
* `PUSH_APNS_PROD_POOL_SIZE` - Connection pool size for `APNS` service in production mode
* `PUSH_APNS_PROD_DEFAULT_TOPIC` - Default `APNS` topic to be set if the client app doesn't specify it with the API call. If this option is not set, MongoosePush will try to extract this value from the provided APNS certificate (the first topic will be assumed default)

### Local build

#### Perquisites

* Elixir 1.4+ (http://elixir-lang.org/install.html)
* Rebar3 (just enter ```mix local.rebar```)

#### Build and run

Build step is really easy. Just type in root of the repository:
```bash
MIX_ENV=prod mix do deps.get, compile, certs.dev, release
```

After this step you may try to run the service via:
```bash
_build/prod/rel/mongoose_push/bin/mongoose_push console
```

Yeah, I know... It crashed. Running this service is fast and simple but unfortunately you can't have push notifications without properly configured `FCM` and/or `APNS` service. So, lets configure it!

## Configuration

The whole configuration is contained in file `config/{prod|dev|test}.exs` depending on which `MIX_ENV` you will be using. You should use `MIX_ENV=prod` for production installations and `MIX_ENV=dev` for your development. Anyway, lets take a look on `config/dev.exs`, part by part.

### REST API configuration

```elixir
config :maru, MongoosePush.Router,
    versioning: [
        using: :path
    ],
    https: [
        ip: {127, 0, 0, 1},
        port: 8443,
        keyfile: "priv/ssl/fake_key.pem",
        certfile: "priv/ssl/fake_cert.pem",
        otp_app: :mongoose_push
    ]
```

This part of configuration relates only to `REST` endpoints that `MongoosePush` exposes. Here you can set bind IP adress (option: `ip`), port and paths to your `HTTP` `TLS` certificates. You should ignore other options unless you know what you're doing or you're going to get to know by reading [maru's documentation](https://maru.readme.io/docs).

You may entirely skip the `maru` config entry to disable `REST` API and just use this project as `Elixir` library.

### FCM configuration
Lets take a look at sample `FCM` service configuration:
```elixir
config :mongoose_push, fcm: [
    default: [
        key: "fake_app_key",
        pool_size: 5,
        mode: :prod
    ]
  ]
```

Here we can see definition of a pool. Each pool has a name and its configuration. You may have several named pools of different sizes and with different configurations. Currently the only reason you may want to do this is that, the `REST` client may switch between them by specifying matching `:mode` in their push request.

Each `FCM` pool may be configured by setting the following fields:
* **key** (*required*) - you `FCM` Application Key for using Googles API
* **pool_size** (*required*) - maximum number of used `HTTP/2` connections to google's service
* **mode** (*either `:prod` or `:dev`*) - pool's mode. `REST` client may select pool used to push his notification by specifying matching option in his request
* **endpoint** (*optional*) - URL override for `FCM` service. Useful mainly in tests

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
     pool_size: 5
   ],
   prod: [
     cert: "priv/apns/prod_cert.pem",
     key: "priv/apns/prod_key.pem",
     mode: :prod,
     use_2197: false,
     pool_size: 5
   ]
 ]
 ```
Analogically to `FCM` configuration, at top level we may specify named pools that have different configurations. For `APNS` this is specifically useful since Apple delivers different APS certificated for development and production use. As in `FCM`, `REST` client may select named pool by providing matching `:mode` in his `REST` request.

Each `APNS` pool may be configured by setting the following fields:
* **cert** (*required*) - relative path to `APNS` `PEM` certificate issued by Apple. This certificate have to be somewhere in `priv` directory
* **key** (*required*) - relative path to `PEM` private key for `APNS` certificate issued by Apple. This file have to be somewhere in `priv` directory
* **pool_size** (*required*) - maximum number of used `HTTP/2` connections to google's service
* **mode** (*either `:prod` or `:dev`*) - pool's mode. `REST` client may select pool used to push his notification by specifying matching option in his request
* **endpoint** (*optional*) - URL override for `APNS` service. Useful mainly in tests
* **use_2197** (*optional `true` or `false`*) - whether use alternative port for `APNS`: 2197

You may entirely skip the `APNS` config entry to disable `APNS` support.

#### Converting APNS files

If you happen to have APNS files in `pkcs12` format (.p12 or .pfx extenstion) you need to convert them to `PEM` format which is understood by MongoosePush. Belowe you can find sample `openssl` commands which may be helpful.

##### Get cert from pkcs12 file

    openssl pkcs12 -in YourAPNS.p12 -out YourCERT.pem -nodes -nokeys

#### Get key from pkcs12 file

    openssl pkcs12 -in YourAPNS.p12 -out YourKEY.pem -nodes -nocerts



## REST API

### Swagger

If for some reason you need `Swagger` spec for this `REST` service, there is swagger endpoint available at `REST` path `/swagger.json`

### Just tell me what to send already

There is only one endpoint at this moment:
* `POST /v2/notification/{device_id}`

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
* **mutable_content** (*optional*, `true` / `false` (default)) - Only applicable to APNS. Sets "mutable-content=1" in APNS payload.
* **topic** (*optional*, `APNS` specific) - if APNS certificate configured in `MongoosePush` allows for multiple applications, this field selects the application. Please refer to `APNS` documentation for more datails
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

## Metrics

MongoosePush supports metrics based on `elixometer`. In order to enable metrics, you need to add an `elixometer` configuration in the config file matching your release type (or simply `sys.config` when you need this on already released MongoosePush). The following example config will enable simplest reporter - TTY (already enabled in `:dev` environment):

```elixir
config :exometer_core, report: [reporters: [{:exometer_report_tty, []}]]
config :elixometer, reporter: :exometer_report_tty,
     env: Mix.env,
     metric_prefix: "mongoose_push"
```

The example below on the other hand will enable `graphite` reporter (replace GRAPHITE_OPTIONS with a list of options for `graphite`):

```elixir
config :exometer_core, report: [reporters: [{:exometer_report_graphite, GRAPHITE_OPTIONS}]]
config :elixometer, reporter: :exometer_report_graphite,
      env: Mix.env,
      metric_prefix: "mongoose_push"
```

### Available metrics

The following metrics are available:
* `mongoose_push.${METRIC_TYPE}.push.${SERVICE}.${MODE}.error.all`
* `mongoose_push.${METRIC_TYPE}.push.${SERVICE}.${MODE}.error.${REASON}`
* `mongoose_push.${METRIC_TYPE}.push.${SERVICE}.${MODE}.success`

Where:
* **METRIC_TYPE** is either `timers` or `spirals`
* **SERVICE** is either `fcm` or `apns`
* **MODE** is either `prod` or `dev`
* **REASON** is an arbitrary error reason term
