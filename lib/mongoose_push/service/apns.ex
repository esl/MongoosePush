defmodule MongoosePush.Service.APNS do
  @moduledoc """
  APNS (apple Push Notification Service) service provider implementation.
  """

  @behaviour MongoosePush.Service
  alias Pigeon.APNS
  alias MongoosePush.Service

  @spec prepare_notification(string, MongoosePush.request) ::
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
    APNS.Notification.new(device_id, request[:topic])
  end

  @spec push(Service.notification, string, atom) :: :ok | {:error, term}
  def push(notification, _device_id, worker) do
    case APNS.push(notification, [name: worker]) do
      {:ok, _state} ->
        :ok
      {:error, reason, _state} ->
        {:error, reason}
    end
  end

end
