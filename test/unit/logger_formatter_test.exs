defmodule MongoosePush.LoggerFormatterTest do
  use ExUnit.Case

  alias MongoosePush.Logger.{JSON, LogFmt}

  describe "format/4" do
    setup do
      {date, time} =
        :millisecond
        |> System.system_time()
        |> :calendar.system_time_to_universal_time(:millisecond)

      %{
        date_time: {date, Tuple.append(time, 0)},
        severity: Enum.random(["info", "debug", "error", "warn"]),
        what: "Something",
        pid: self()
      }
    end

    test "prints logs in JSON format", %{
      date_time: date_time,
      severity: severity,
      what: what,
      pid: pid
    } do
      assert {:ok,
              %{
                "application" => "mongoose_push",
                "at" => "Module.function/1:1",
                "pid" => pid,
                "severity" => severity,
                "text" => "Some random message",
                "what" => what,
                "when" => date_time
              }} =
               JSON.format(
                 String.to_atom(severity),
                 "Some random message",
                 date_time,
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
      date_time: date_time,
      severity: severity,
      what: what,
      pid: pid
    } do
      assert %{
               "application" => "mongoose_push",
               "at" => "Module.function/1:1",
               "pid" => pid,
               "severity" => severity,
               "text" => "Some random message",
               "what" => what,
               "when" => date_time
             } =
               LogFmt.format(
                 String.to_atom(severity),
                 "Some random message",
                 date_time,
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
