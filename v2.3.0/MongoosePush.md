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

Raw push request. `:service` and at least one of `:alert` or `:data` are required.

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
The request requires `:service` (`:fcm` or `:apns`) and at least one of
`:alert` or `:data`. Without `:alert`, the notification is silent.

`:data` contains application-specific key-value data. In a data-only request,
`%{"type" => "jmi"}` identifies a Jingle Message Initiation call notification.
FCM derives its collapse key from a non-empty `"jmi-sid"`. For APNS, this creates
a VoIP notification and requires a PushKit token and a `.voip` topic.

An `:alert` requires `:title` and `:body` and may include `:sound`,
`:click_action`, `:tag` (FCM), or `:badge` (APNS).

`:priority` accepts `:normal` or `:high`; APNS maps them to `"5"` and `"10"`.

`:mode` selects the `:prod` (default) or `:dev` pool.

`:mutable_content` enables the corresponding APS option for non-JMI notifications.

