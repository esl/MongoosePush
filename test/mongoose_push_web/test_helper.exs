{:ok, _} = Application.ensure_all_started(:mongoose_push)

Mox.defmock(MongoosePush.Notification.MockImpl, for: MongoosePush.Notification)
