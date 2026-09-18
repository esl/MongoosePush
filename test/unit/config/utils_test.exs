defmodule MongoosePush.Config.UtilsTest do
  use ExUnit.Case

  alias MongoosePush.Config.Utils

  test "parses FCM JMI priority" do
    assert {:ok, :normal} == Utils.parse_fcm_jmi_priority("normal")
    assert {:ok, :high} == Utils.parse_fcm_jmi_priority("high")
    assert {:error, _reason} = Utils.parse_fcm_jmi_priority("urgent")
  end
end
