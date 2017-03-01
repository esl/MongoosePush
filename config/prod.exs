use Mix.Config

config :mix_docker, image: "mongoose_push"

config :maru, MongoosePush.Router,
    versioning: [
        using: :path
    ],
    https: [
        bind_addr:  {:system, :string,  "PUSH_HTTPS_BIND_ADDR", "127.0.0.1"},
        port:       {:system, :integer, "PUSH_HTTPS_PORT",      8443},
        keyfile:    {:system, :string,  "PUSH_HTTPS_KEYFILE",   "priv/ssl/fake_key.pem"},
        certfile:   {:system, :string,  "PUSH_HTTPS_CERTFILE",  "priv/ssl/fake_cert.pem"},
        acceptors:  {:system, :integer, "PUSH_HTTPS_ACCEPTORS", 100},
        otp_app: :mongoose_push
    ]

config :mongoose_push, loglevel:
  {:system, :atom, "PUSH_LOGLEVEL", :info}
config :mongoose_push, fcm_enabled:
  {:system, :boolean, "PUSH_FCM_ENABLED", true}

config :mongoose_push, apns_enabled:
  {:system, :boolean, "PUSH_APNS_ENABLED", true}

config :mongoose_push, fcm: [
  default: [
    endpoint:   {:system, :string,  "PUSH_FCM_ENDPOINT",   nil},
    key:        {:system, :string,  "PUSH_FCM_APP_KEY",    "fake_app_key"},
    pool_size:  {:system, :integer, "PUSH_FCM_POOL_SIZE",  5},
    mode:       :prod,
  ]
]

config :mongoose_push, apns: [
  dev: [
    endpoint:    {:system, :string,  "PUSH_APNS_DEV_ENDPOINT",    nil},
    cert:        {:system, :string,  "PUSH_APNS_DEV_CERT",        "priv/apns/dev_cert.pem"},
    key:         {:system, :string,  "PUSH_APNS_DEV_KEY",         "priv/apns/dev_key.pem"},
    mode:        :dev,
    use_2197:    {:system, :boolean, "PUSH_APNS_DEV_USE_2197",    false},
    pool_size:   {:system, :integer, "PUSH_APNS_DEV_POOL_SIZE",   5}
  ],
  prod: [
    endpoint:    {:system, :string,  "PUSH_APNS_PROD_ENDPOINT",   nil},
    cert:        {:system, :string,  "PUSH_APNS_PROD_CERT",       "priv/apns/prod_cert.pem"},
    key:         {:system, :string,  "PUSH_APNS_PROD_KEY",        "priv/apns/prod_key.pem"},
    mode:        :prod,
    use_2197:    {:system, :boolean, "PUSH_APNS_PROD_USE_2197",   false},
    pool_size:   {:system, :integer, "PUSH_APNS_PROD_POOL_SIZE",  5}
  ]
]
