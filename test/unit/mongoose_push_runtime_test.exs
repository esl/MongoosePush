defmodule MongoosePushRuntimeTest do
  use ExUnit.Case, async: false

  setup do
    TestHelper.reload_app()
  end

  test "tls ciphers required by apns are available" do
    assert :ok == MongoosePush.Application.check_apns_ciphers()
  end
end
