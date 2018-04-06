defmodule MongoosePush.Service.APNS do
  @moduledoc """
  APNS (apple Push Notification Service) service provider implementation.
  """

  @behaviour MongoosePush.Service
  require Logger
  alias Pigeon.APNS
  alias Pigeon.APNS.Config
  alias Pigeon.APNS.Notification
  alias MongoosePush.Service
  alias MongoosePush.Pools
  alias MongoosePush.Service.APNS.Certificate

  @priority_mapping %{normal: "5", high: "10"}

  @spec prepare_notification(String.t(), MongoosePush.request) ::
    Service.notification
  def prepare_notification(device_id, %{alert: nil} = request) do
    # Setup silent notification
    %{"content-available" => 1}
    |> Notification.new(device_id, request[:topic], request[:data])
    |> maybe_mutable_content(request[:mutable_content])
    |> Notification.put_priority(@priority_mapping[request[:priority]])
  end
  def prepare_notification(device_id, request) do
    # Setup non-silent notification
    alert = request.alert
    %{
      "alert" => %{
        "title" => alert.title,
        "body" => alert.body
      },
      "badge" => alert[:badge],
      "category" => alert[:click_action],
      "sound" => alert[:sound]
    }
    |> Notification.new(device_id, request[:topic], request[:data])
    |> maybe_mutable_content(request[:mutable_content])
    |> Notification.put_priority(@priority_mapping[request[:priority]])
  end

  @spec push(Service.notification(), String.t(), atom(), Service.options()) ::
    :ok | {:error, term}
  def push(notification, _device_id, worker, opts \\ []) do
    case APNS.push(notification, Keyword.merge([name: worker], opts)) do
      {:ok, _state} ->
        :ok
      {:error, reason, _state} ->
        {:error, reason}
    end
  end

  @spec workers({atom, Keyword.t()} | nil) :: list(Supervisor.Spec.spec())
  def workers(nil), do: []
  def workers({pool_name, pool_config}) do
    pool_size = pool_config[:pool_size]
    pool_config =
      pool_config
      |> construct_apns_endpoint_options()
      |> announce_subject()
      |> maybe_setup_default_apns_topic()

    Enum.map(1..pool_size, fn(id) ->
        worker_name = Pools.worker_name(:apns, pool_name, id)
        worker_config = Config.config(worker_name, pool_config)
        Supervisor.Spec.worker(Pigeon.APNSWorker,
                               [worker_config], [id: worker_name])
    end)
  end

  defp construct_apns_endpoint_options(config) do
    new_key = case config[:mode] do
      :dev -> :development_endpoint
      :prod -> :production_endpoint
    end
    Enum.into([{new_key, config[:endpoint]}], config)
  end

  defp announce_subject(config) do
    try do
      subject = Certificate.extract_subject!(config[:cert])
      Logger.info(~s"Using APNS certificate '#{subject}' for '#{config[:mode]}' connection pool")
    catch
      _, reason ->
        Logger.warn(~s"Unable to extract APNS certificate's subject from the #{config[:mode]} " <>
                      "certificate due to: #{inspect reason}")
    end

    config
  end

  defp maybe_setup_default_apns_topic(config) do
    try do
      # There are loooots of things that may went wrong with this. Notably, dev certificates
      # don't have topic list, while production certificates may not have it if they are old enough.
      # Also the whole `extract_topics!` function is based on reverse-engineered ASN.1 struct,
      # so there may be some incompability issues that we may work on based on failure logs.
      case config[:default_topic] do
        nil ->
          all_topics = Certificate.extract_topics!(config[:cert])
          default_topic = all_topics[:topic]
          Logger.info(~s"Successfully extracted default APNS topic: #{default_topic}")
          Enum.into([default_topic: default_topic], config)
        default_topic ->
          Logger.info(~s"Using user-defined default APNS topic: #{default_topic}")
          config
      end
    catch
      _, reason ->
        Logger.warn(~s"Unable to extract APNS topic from the #{config[:mode]} certificate " <>
                    "due to: #{inspect reason}")
        config
    end
  end

  defp maybe_mutable_content(notification, true), do: Notification.put_mutable_content(notification)
  defp maybe_mutable_content(notification, _),    do: notification

end
