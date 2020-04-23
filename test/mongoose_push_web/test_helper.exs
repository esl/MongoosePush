{:ok, _} = Application.ensure_all_started(:mongoose_push)
ExUnit.start(capture: true)

Mox.defmock(MongoosePush.Notification.MockImpl, for: MongoosePush.Notification)
