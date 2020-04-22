{:ok, _} = Application.ensure_all_started(:mongoose_push)
ExUnit.start(capture: true)

defmodule Mocks do
  Mox.defmock(MongoosePushBehaviourMock, for: MongoosePushBehaviour)
end
