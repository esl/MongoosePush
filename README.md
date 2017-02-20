# MongoosePush

[![Build Status](https://travis-ci.org/esl/MongoosePush.svg?branch=master)](https://travis-ci.org/esl/MongoosePush) [![Coverage Status](https://coveralls.io/repos/github/esl/MongoosePush/badge.svg?branch=master)](https://coveralls.io/github/esl/MongoosePush?branch=master)

**MongoosePush** is simple (seriously) **REST** service written in **Elixir** providing ability to **send push
notification** to `FCM` (Firebase Cloud Messaging) and/or
`APNS` (Apple Push Notification Service) via their `HTTP/2` API.

## Quick start

### Docker

Soon :)

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

The whole configuration is contained in file `config/{prod|dev|test}.exs` depending on which `MIX_ENV` you will be using. You should use `MIX_ENV=prod` for production installations and `MIX_ENV=dev` for your development. Anyway, lets take a look on `config/prod.exs`, part by part.  

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

This part of configuration relates only to `REST` endpoints that `MongoosePush` exposes. Here you can set bind IP adress (option: `ip`), port and paths to you `HTTP` `TLS` certificates. You should ignore other options unless you know what you're doing or you're going to get to know by reading [maru's documentation](https://maru.readme.io/docs).

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

## REST API

### Swagger

If for some reason you need `Swagger` spec for this `REST` service, after compiling and running this project with `MIX_ENV=dev`, there is swagger endpoint available at `REST` path `/swagger.json`

### Just tell me what to send already

There is only one endpoint at this moment:
* `POST /v1/notification/{device_id}`

As you can imagine, `{device_id}` should be replaced with device ID/Token generated by your push notification provider (`FCM` or `APNS`). The notification should be sent as `JSON` payload of this request. Minimal `JSON` request could be like this:

```json
{
  "service": "apns",
  "body": "notification's text body",
  "title": "notification's title"
}
```

The full list of options contains the following:
* **service** (*required*, `apns` or `fcm`) - push notifications provider to be used for this notification
* **body** (*required*) - text body of notification
* **title** (*required*) - short title of notification
* **mode** (*optional*, `prod` (default) or `dev`) - allows for selecting named pool configured in `MongoosePush`
* **click_action** (*optional*) - for `FCM` its `activity` to run when notification is clicked. For `APNS` its `category` to invoke. Please refer to Android/iOS documentation for more details about this action
* **tag** (*optional*, `FCM` specific) - notifications aggregation key
* **badge** (*optional*, `APNS` specific) - unread notifications count
* **topic** (*optional*, `APNS` specific) - if APNS certificate configured in `MongoosePush` allows for multiple applications, this field selects the application. Please refer to `APNS` documentation for more datails
