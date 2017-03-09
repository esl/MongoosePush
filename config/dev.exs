use Mix.Config

config :exometer_core, report: [reporters: [{:exometer_report_tty, []}]]
config :elixometer, reporter: :exometer_report_tty,
     env: Mix.env,
     metric_prefix: "mongoose_push"

config :mongoose_push, loglevel: :debug

config :maru, MongoosePush.Router,
    versioning: [
        using: :path
    ],
    https: [
        bind_addr: "127.0.0.1",
        port: 8443,
        keyfile: "priv/ssl/fake_key.pem",
        certfile: "priv/ssl/fake_cert.pem",
        otp_app: :mongoose_push
    ]

config :mongoose_push, fcm: [
    default: [
        endpoint: "localhost",
        key: "fake_app_key",
        pool_size: 5,
        mode: :prod
    ]
  ]

config :mongoose_push, apns: [
   dev: [
     endpoint: "localhost",
     cert: "priv/apns/dev_cert.pem",
     key: "priv/apns/dev_key.pem",
     mode: :dev,
     use_2197: true,
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
