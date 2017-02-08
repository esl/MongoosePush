use Mix.Config

config :maru, MongoosePush.Router,
    versioning: [
        using: :path
    ],
    https: [
        ip: {127, 0, 0, 1},
        port: 9090,
        keyfile: "priv/ssl/fake_key.pem",
        certfile: "priv/ssl/fake_cert.pem",
        otp_app: :mongoose_push
    ]

config :mongoose_push, fcm: [
    prod: [
        key: "fake_app_key",
        endpoint: "localhost",
        pool_size: 5
    ]
  ]

config :mongoose_push, apns: [
   dev1: [
     development_endpoint: "localhost",
     production_endpoint: "localhost",
     cert: "priv/apns/app_cert.pem",
     key: "priv/apns/app_key.pem",
     mode: :dev,
     use_2197: true,
     pool_size: 1
   ],
   prod1: [
     development_endpoint: "localhost",
     production_endpoint: "localhost",
     cert: "priv/apns/app_cert.pem",
     key: "priv/apns/app_key.pem",
     mode: :prod,
     use_2197: true,
     pool_size: 2
   ],
   dev2: [
     development_endpoint: "localhost",
     production_endpoint: "localhost",
     cert: "priv/apns/app_cert.pem",
     key: "priv/apns/app_key.pem",
     mode: :dev,
     use_2197: true,
     pool_size: 3
   ],
   prod2: [
     development_endpoint: "localhost",
     production_endpoint: "localhost",
     cert: "priv/apns/app_cert.pem",
     key: "priv/apns/app_key.pem",
     mode: :prod,
     use_2197: true,
     pool_size: 4
   ]
 ]
