Code.put_compiler_option(:warnings_as_errors, true)

ExUnit.start(capture_log: true)
Mox.defmock(MongoosePush.Service.Mock, for: MongoosePush.Service)
