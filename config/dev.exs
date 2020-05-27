use Mix.Config

config :mongoose_push, loglevel: :debug

config :mongoose_push,
  openapi: [
    expose_spec: true,
    expose_ui: true
  ]

config :goth, endpoint: "http://fcm-mock:4001"

config :mongoose_push,
  fcm: [
    default: [
      endpoint: "localhost",
      port: 4000,
      appfile: "priv/fcm/token.json",
      pool_size: 5,
      mode: :prod,
      tls_opts: []
    ]
  ]

config :mongoose_push,
  apns: [
    dev: [
      auth: %{
        type: :certificate,
        cert: "priv/apns/dev_cert.pem",
        key: "priv/apns/dev_key.pem"
      },
      endpoint: "localhost",
      mode: :dev,
      use_2197: true,
      pool_size: 5,
      tls_opts: []
    ],
    prod: [
      auth: %{
        type: :certificate,
        cert: "priv/apns/prod_cert.pem",
        key: "priv/apns/prod_key.pem"
      },
      endpoint: "localhost",
      mode: :prod,
      use_2197: true,
      pool_size: 5,
      tls_opts: []
    ]
  ]

config :mongoose_push, MongoosePushWeb.Endpoint,
  https: [
    port: 8443,
    keyfile: "priv/ssl/fake_key.pem",
    certfile: "priv/ssl/fake_cert.pem",
    otp_app: :mongoose_push
  ],
  debug_errors: true,
  code_reloader: false,
  check_origin: false,
  server: true
