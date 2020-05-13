defmodule MongoosePush.Telemetry do
  @moduledoc """
  Generic Telemetry handler interface
  """
  @type event_name :: [atom]
  @type measurements :: map()
  @type metadata :: map()
  @type config :: term()

  @callback event_names() :: [event_name]
  @callback handle_event(event_name, measurements, metadata, config) :: :ok

  @handlers [
    MongoosePush.Metrics.ExometerHandlers
  ]

  def attach_all do
    for handler <- @handlers do
      _ =
        :telemetry.attach_many(
          to_string(handler),
          handler.event_names(),
          &handler.handle_event/4,
          nil
        )
    end
  end
end
