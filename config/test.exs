use Mix.Config

config :mongoose_push, loglevel: :debug

config :elixometer, reporter: :exometer_report_tty,
     env: Mix.env,
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

config :mongoose_push, fcm: [
    default: [
        key: "fake_app_key",
        endpoint: "localhost",
        pool_size: 5,
        mode: :prod
    ]
  ]

config :mongoose_push, apns: [
   dev1: [
     endpoint: "localhost",
     cert: "priv/apns/dev_cert.pem",
     key: "priv/apns/dev_key.pem",
     mode: :dev,
     use_2197: true,
     pool_size: 1,
     default_topic: "dev_topic"
   ],
   prod1: [
     endpoint: "localhost",
     cert: "priv/apns/prod_cert.pem",
     key: "priv/apns/prod_key.pem",
     use_2197: true,
     pool_size: 2,
     default_topic: "prod1_override_topic"
   ],
   dev2: [
     endpoint: "localhost",
     cert: "priv/apns/dev_cert.pem",
     key: "priv/apns/dev_key.pem",
     mode: :dev,
     use_2197: true,
     pool_size: 3
   ],
   prod2: [
     endpoint: "localhost",
     cert: "priv/apns/prod_cert.pem",
     key: "priv/apns/prod_key.pem",
     mode: :prod,
     use_2197: true,
     pool_size: 4
   ]
 ]
