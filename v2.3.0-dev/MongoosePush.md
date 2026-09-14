# `MongoosePush`
[🔗](https://github.com/esl/MongoosePush/blob/main/lib/mongoose_push.ex#L1)

MongoosePush is simple (seriously) service providing ability to send push
notification to `FCM` (Firebase Cloud Messaging) and/or
`APNS` (Apple Push Notification Service). What makes it cool is not only
simplicity but also support for newest and fastest `HTTP/2` based APIs
for both services.

At this moment only those two services are supported but in future
MongoosePush may and probably will support even more Push Notification Services.

# `alert`

```elixir
@type alert() :: %{required(alert_key()) =&gt; atom() | String.t() | integer()}
```

# `alert_key`

```elixir
@type alert_key() :: :title | :body | :tag | :badge | :click_action | :sound
```

# `data`

```elixir
@type data() :: %{required(data_key()) =&gt; term()}
```

# `data_key`

```elixir
@type data_key() :: atom() | String.t()
```

# `error`

```elixir
@type error() ::
  {:generic, :no_matching_pool | :unable_to_connect | :connection_lost | atom()}
```

# `mode`

```elixir
@type mode() :: :dev | :prod
```

# `req_key`

```elixir
@type req_key() ::
  :service
  | :mode
  | :alert
  | :data
  | :topic
  | :priority
  | :time_to_live
  | :mutable_content
  | :tags
```

Available keys in `request` map

# `request`

```elixir
@type request() :: %{
  required(req_key()) =&gt; atom() | String.t() | integer() | alert() | data()
}
```

Raw push request. The keys: `:service` and at least one of `:alert` or `:body` are required

# `service`

```elixir
@type service() :: :fcm | :apns
```

# `push`

```elixir
@spec push(String.t(), request()) ::
  :ok | {:error, MongoosePush.Service.error()} | {:error, error()}
```

Push notification defined by `request` to device with `device_id`.
`request` has to define at least `:service` type (`:fcm` or `:apns`) and
at least one of `:alert` or `:data`. If `alert` is not present, the notification will be send as 'silent'.
Please refer to yours push notification service provider's documentation for more details on
silent notifications.

Field `:data` may contain any custom data that have to be delivered to the target device, while
field `:alert`, if present, must contain at least `:title` and `:body`. The `:alert` field may also
contain: :sound, `:tag` (option specific to FCM service), `:topic` and `:bagde` (specific to APNS).
Please consult push notification service provider's documentation for more informations on those
optional fields.

Field `:priority` may be used to set priority for message on both FCM and APNS. The values are
native for FCM and for APNS - :normal is "5" and :high is 10.

`:mode` option is also specific to APNS but it only selects appropriate
worker pool (with `:mode` set to either `:prod` or `:dev`).
Default value to `:mode` is `:prod`.

Field `:mutable_content` (specific to APNS) can be set to `true` (by default `false`) to enable
this feature (please consult APNS documentation for more information).

