use Mix.Config

config :mongoose_push, loglevel: :debug

config :elixometer,
  reporter: :exometer_report_tty,
  env: Mix.env(),
  metric_prefix: "mongoose_push"

config :maru, MongoosePush.Router,
  versioning: [
    using: :path
  ],
  https: [
    bind_addr: "0.0.0.0",
    port: 8443,
    keyfile: "priv/ssl/fake_key.pem",
    certfile: "priv/ssl/fake_cert.pem",
    otp_app: :mongoose_push
  ]

config :mongoose_push,
  fcm: [
    default: [
      appfile: "priv/fcm/token.json",
      endpoint: "localhost",
      pool_size: 5,
      mode: :prod,
      port: 4000
    ]
  ]

config :mongoose_push,
  apns: [
    dev1: [
      auth: %{
        type: :certificate,
        cert: "priv/apns/dev_cert.pem",
        key: "priv/apns/dev_key.pem"
      },
      endpoint: "localhost",
      mode: :dev,
      use_2197: true,
      pool_size: 1,
      default_topic: "dev_topic"
    ],
    prod1: [
      auth: %{
        type: :certificate,
        cert: "priv/apns/prod_cert.pem",
        key: "priv/apns/prod_key.pem"
      },
      endpoint: "localhost",
      use_2197: true,
      pool_size: 2,
      default_topic: "prod1_override_topic"
    ],
    dev2: [
      auth: %{
        type: :certificate,
        cert: "priv/apns/dev_cert.pem",
        key: "priv/apns/dev_key.pem"
      },
      endpoint: "localhost",
      mode: :dev,
      use_2197: true,
      pool_size: 3
    ],
    prod2: [
      auth: %{
        type: :certificate,
        cert: "priv/apns/prod_cert.pem",
        key: "priv/apns/prod_key.pem"
      },
      endpoint: "localhost",
      mode: :prod,
      use_2197: true,
      pool_size: 4
    ],
    dev3: [
      auth: %{
        type: :token,
        key_id: "fake_key",
        team_id: "fake_team",
        p8_file_path: "priv/apns/token.p8"
      },
      endpoint: "localhost",
      mode: :dev,
      use_2197: true,
      pool_size: 3,
      default_topic: "dev_token_topic"
    ],
    prod3: [
      auth: %{
        type: :token,
        key_id: "fake_key",
        team_id: "fake_team",
        p8_file_path: "priv/apns/token.p8"
      },
      endpoint: "localhost",
      mode: :prod,
      use_2197: true,
      pool_size: 3,
      default_topic: "prod_token_topic"
    ]
  ]
