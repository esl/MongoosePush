defmodule MongoosePush.LoggerFormatterTest do
  use ExUnit.Case

  alias MongoosePush.Logger.{JSON, LogFmt}

  describe "format/4" do
    setup do
      %{
        severity: Enum.random(["info", "debug", "error", "warn"]),
        what: "Something",
        pid: self()
      }
    end

    test "prints logs in JSON format", %{
      severity: severity,
      what: what,
      pid: pid
    } do
      assert {:ok,
              %{
                "application" => "mongoose_push",
                "at" => "Module.function/1:1",
                "pid" => inspect(pid),
                "severity" => severity,
                "text" => "Some random message",
                "what" => what,
                "when" => "2022-09-08T09:23:14.001"
              }} ==
               JSON.format(
                 String.to_atom(severity),
                 "Some random message",
                 {{2022, 09, 08}, {09, 23, 14, 001}},
                 application: :mongoose_push,
                 time: :os.system_time(),
                 pid: pid,
                 what: what,
                 module: :Module,
                 function: :"function/1",
                 line: 1
               )
               |> Jason.decode()
    end

    test "prints logs in logfmt format", %{
      severity: severity,
      what: what,
      pid: pid
    } do
      assert %{
               "application" => "mongoose_push",
               "at" => "Module.function/1:1",
               "pid" => inspect(pid),
               "severity" => severity,
               "text" => "Some random message",
               "what" => what,
               "when" => "2022-09-08T09:25:07.002"
             } ==
               LogFmt.format(
                 String.to_atom(severity),
                 "Some random message",
                 {{2022, 09, 08}, {09, 25, 07, 002}},
                 application: :mongoose_push,
                 time: :os.system_time(),
                 pid: pid,
                 what: what,
                 module: :Module,
                 function: :"function/1",
                 line: 1
               )
               |> Logfmt.decode()
    end
  end
end
