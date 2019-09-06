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
    {:ok, %{}}
  end

  defp setup_default_topics(pool_configs) do
    Enum.map(pool_configs, fn {name, config} ->
      {name, setup_default_apns_topic(config)[:default_topic]}
    end)
  end

  def get_default_topic(pool_name) do
    [{_name, topic}] = :ets.lookup(:apns_state, pool_name)
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
          Logger.info(~s"Successfully extracted default APNS topic: #{default_topic}")
          Keyword.put(config, :default_topic, default_topic)

        default_topic ->
          Logger.info(~s"Using user-defined default APNS topic: #{default_topic}")
          config
      end
    catch
      _, reason ->
        Logger.warn(
          ~s"Unable to extract APNS topic from the #{config[:mode]} certificate " <>
            "due to: #{inspect(reason)}"
        )

        config
    end
  end
end
