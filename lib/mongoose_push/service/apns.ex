defmodule MongoosePush.Service.APNS do
  @moduledoc """
  APNS (apple Push Notification Service) service provider implementation.
  """

  @behaviour MongoosePush.Service
  alias Pigeon.APNS
  alias Pigeon.APNS.Config
  alias Pigeon.APNS.Notification
  alias MongoosePush.Service
  alias MongoosePush.Pools

  @spec prepare_notification(String.t(), MongoosePush.request) ::
    Service.notification
  def prepare_notification(device_id, request) do
    %{
      "alert" => %{
        "title" => request.title,
        "body" => request.body
      },
      "badge" => request[:badge],
      "category" => request[:click_action]
    }
    |>
    Notification.new(device_id, request[:topic])
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
    pool_config = construct_apns_endpoint_options(pool_config)
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

end
