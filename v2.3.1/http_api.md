# HTTP API

If for some reason you need `Swagger` specs for this `RESTful` service, there is a swagger endpoint available via an `HTTP` path `/swagger.json`

## Request

MongoosePush exposes one notification endpoint:

* `POST /{version}/notification/{device_id}`

`{device_id}` is the token issued by FCM or APNS. Send the notification as a JSON body, for example:

```json
{
  "service": "apns",
  "alert":
    {
      "body": "notification's text body",
      "title": "notification's title"
    }
}
```

The available options are:

* **service** (*required*, `apns` or `fcm`) - push notifications provider to be used for this notification
* **mode** (*optional*, `prod` (default) or `dev`) - allows for selecting named pool configured in `MongoosePush`
* **priority** (*optional*, `normal` or `high`) - passed through to FCM; for APNS, `normal` maps to `5` and `high` to `10`. FCM JMI notifications default to the selected pool's **jmi_priority** (`high` if unset); otherwise the provider chooses the default.
* **time_to_live** (*optional*, FCM specific) - maximum notification lifespan in seconds, as an integer. FCM JMI notifications default to the selected pool's **jmi_ttl** (`30` if unset). See the [FCM documentation](https://firebase.google.com/docs/cloud-messaging/concept-options#ttl).
* **mutable_content** (*optional*, `true` / `false` (default)) - for non-JMI APNS notifications, sets "mutable-content=1" in the APNS payload.
* **topic** (*optional*, APNS specific) - selects the application when the configured credentials allow multiple topics.
* **tags** (*optional*) - a list of tags used to choose a pool with matching tags. To see how tags work read: https://github.com/esl/sparrow#tags
* **data** (*optional*) - custom JSON sent to the target device. APNS places its keys at the payload root; FCM puts them in `message.data`. JMI delivery options are described below.
* **alert** (*optional*) - JSON structure that if provided will send a non-silent notification with the following fields:
  * **body** (*required*) - text body of the notification
  * **title** (*required*) - short title of the notification
  * **click_action** (*optional*) - for `FCM` its `activity` to run when notification is clicked. For `APNS` its `category` to invoke. Please refer to the Android/iOS documentation for more details about this action
  * **tag** (*optional*, `FCM` specific) - notifications aggregation key
  * **badge** (*optional*, `APNS` specific) - unread notifications count
  * **sound** (*optional*) - sound that should be play when the notification arrives. Please refer to the FCM / APNS documentation for more details.

At least one of **alert** and **data** is required. Supplying only **data** creates a silent notification; supplying **alert** creates a visible notification, optionally with custom **data**.

### JMI call notifications

Set `data.type` to `jmi` and omit `alert` to send an incoming Jingle Message Initiation call notification. For FCM, a non-empty `data.jmi-sid` is recommended so MongoosePush can generate a collapse key.

For FCM, post to `/v3/notification/{fcm_token}`:

```json
{
  "service": "fcm",
  "data": {
    "type": "jmi",
    "jmi-sid": "ca3cf894-5325-482f-a412-a6e9f832298d",
    "jmi-from": "romeo@montague.example/orchard"
  }
}
```

MongoosePush puts the data at the FCM message level and, when `jmi-sid` is a non-empty string, derives `collapse_key` as `"jmi-" + jmi-sid`. Priority and TTL come from the selected pool's `jmi_priority` and `jmi_ttl`; request-level `priority` and `time_to_live` override them.

For APNS, use the PushKit token as `{device_id}` and post to `/v3/notification/{device_id}`:

```json
{
  "service": "apns",
  "topic": "com.example.app.voip",
  "data": {
    "type": "jmi",
    "jmi-sid": "ca3cf894-5325-482f-a412-a6e9f832298d",
    "jmi-from": "romeo@montague.example/orchard"
  }
}
```

The topic must end in `.voip`. MongoosePush sets the APNS push type to `voip` and expiration to `0`, puts the data at the payload root, and omits `aps`.

## Response 

Description of the possible server responses

* **200** `"OK"` - the request was successful.
* **400** `{"reason" : "invalid_request"|"no_matching_pool"}` - the request was invalid.
* **410** `{"reason" : "unregistered"}` - the device was not registered.
* **413** `{"reason" : "payload_too_large"}` - the payload was too large.
* **429** `{"reason" : "too_many_requests"}` - there were too many requests to the server.
* **503** `{"reason" : "service_internal"|"internal_config"|"unspecified"}` - the internal service or configuration error occurred.
* **520** `{"reason" : "unspecified"}` - the unknown error occurred.
* **500** `{"reason" : reason}` - the server internal error occurred,
  specified by **reason**.
