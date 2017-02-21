use Mix.Config

config :maru, MongoosePush.Router,
    versioning: [
        using: :path
    ],
    https: [
        ip: {127, 0, 0, 1},
        port:     {:system, :integer, "HTTPS_PORT",     8443},
        keyfile:  {:system, :string,  "HTTPS_KEYFILE",  "priv/ssl/fake_key.pem"},
        certfile: {:system, :string,  "HTTPS_CERTFILE", "priv/ssl/fake_cert.pem"},
        otp_app: :mongoose_push
    ]

config :mongoose_push, fcm_enabled:
  {:system, :boolean, "FCM_ENABLED", true}

config :mongoose_push, apns_enabled:
  {:system, :boolean, "APNS_ENABLED", true}

config :mongoose_push, fcm: [
  default: [
    key:        {:system, :string,  "FCM_APP_KEY",    "fake_app_key"},
    pool_size:  {:system, :integer, "FCM_POOL_SIZE",  5},
    mode:       {:system, :atom,    "FCM_MODE",       :prod},
  ]
]

config :mongoose_push, apns: [
  dev: [
     cert:        {:system, :string,  "APNS_DEV_CERT",        "priv/apns/dev_cert.pem"},
     key:         {:system, :string,  "APNS_DEV_KEY",         "priv/apns/dev_key.pem"},
     mode:        {:system, :atom,    "APNS_DEV_MODE",        :dev},
     use_2197:    {:system, :boolean, "APNS_DEV_USE_2197",    false},
     pool_size:   {:system, :integer, "APNS_DEV_POOL_SIZE",   5}
  ],
  prod: [
    cert:        {:system, :string,  "APNS_PROD_CERT",       "priv/apns/prod_cert.pem"},
    key:         {:system, :string,  "APNS_PROD_KEY",        "priv/apns/prod_key.pem"},
    mode:        {:system, :atom,    "APNS_PROD_MODE",       :prod},
    use_2197:    {:system, :boolean, "APNS_PROD_USE_2197",   false},
    pool_size:   {:system, :integer, "APNS_PROD_POOL_SIZE",  5}
  ]
]
