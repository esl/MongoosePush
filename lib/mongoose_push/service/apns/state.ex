defmodule MongoosePush.Service.APNS.State do
  @moduledoc """
  Module for storing state of apns APNS configurations, namely default topics
  """
  use GenServer
  require Logger
  alias MongoosePush.Service.APNS.Certificate

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  @impl true
  def init(pool_configs) do
    default_topics = setup_default_topics(pool_configs)
    :apns_state = :ets.new(:apns_state, [:set, :public, :named_table])
    true = :ets.insert(:apns_state, default_topics)

    :telemetry.execute(
      [:mongoose_push, :apns, :state, :init],
      %{},
      %{
        default_topics: default_topics
      }
    )

    {:ok, %{}}
  end

  @impl true
  def terminate(reason, _state) do
    :telemetry.execute(
      [:mongoose_push, :apns, :state, :terminate],
      %{},
      %{
        reason: reason
      }
    )

    :ok
  end

  defp setup_default_topics(pool_configs) do
    Enum.map(pool_configs, fn {name, config} ->
      {name, setup_default_apns_topic(config)[:default_topic]}
    end)
  end

  def get_default_topic(pool_name) do
    [{_name, topic}] = :ets.lookup(:apns_state, pool_name)

    :telemetry.execute(
      [:mongoose_push, :apns, :state, :get_default_topic],
      %{},
      %{
        topic: topic
      }
    )

    topic
  end

  defp setup_default_apns_topic(config) do
    try do
      # There are loooots of things that may have gone wrong with this. Notably, dev certificates
      # don't have topic list, while production certificates may not have it if they are old enough.
      # Also the whole `extract_topics!` function is based on reverse-engineered ASN.1 struct,
      # so there may be some incompability issues that we may work on based on failure logs.
      case config[:default_topic] do
        nil ->
          all_topics = Certificate.extract_topics!(config[:auth][:cert])
          default_topic = all_topics[:topic]

          Logger.info(
            fn ->
              "extract_default_topic"
            end,
            result: :ok,
            log: :trace,
            topic: default_topic
          )

          Keyword.put(config, :default_topic, default_topic)

        default_topic ->
          Logger.info(
            fn ->
              "use_user_defined_topic"
            end,
            result: :ok,
            log: :trace,
            topic: default_topic
          )

          config
      end
    catch
      _, reason ->
        Logger.warn(
          fn ->
            "extract_topic_from_cert"
          end,
          result: :error,
          log: :trace,
          mode: config[:mode],
          reason: reason
        )

        config
    end
  end
end
