defmodule MongoosePushWeb.APIv3.NotificationController do
  alias MongoosePushWeb.Schemas
  alias OpenApiSpex.Operation
  use MongoosePushWeb, :controller

  use MongoosePushWeb.Schemas

  plug(OpenApiSpex.Plug.CastAndValidate)

  @spec send_operation() :: Operation.t()
  def send_operation() do
    %Operation{
      tags: ["apiv3"],
      summary: "sends a push",
      description: "performs the sending of push notification",
      operationId: "APIv3.NotificationController.send",
      parameters: [
        Operation.parameter(:device_id, :path, :string, "Device ID",
          example: "f53453455",
          required: true
        )
      ],
      requestBody:
        Operation.request_body(
          "The push notification attributes",
          "application/json",
          Schemas.Request.SendNotification.Deep,
          required: true
        ),
      responses: %{
        200 =>
          Operation.response(
            "PushNotification",
            "application/json",
            nil
          ),
        400 =>
          Operation.response(
            "PushNotification",
            "application/json",
            Schemas.Response.SendNotification.GenericError
          ),
        410 =>
          Operation.response(
            "PushNotification",
            "application/json",
            Schemas.Response.SendNotification.Gone
          ),
        413 =>
          Operation.response(
            "PushNotification",
            "application/json",
            Schemas.Response.SendNotification.PayloadTooLarge
          ),
        429 =>
          Operation.response(
            "PushNotification",
            "application/json",
            Schemas.Response.SendNotification.TooManyRequests
          ),
        500 =>
          Operation.response(
            "PushNotification",
            "application/json",
            Schemas.Response.SendNotification.GenericError
          ),
        503 =>
          Operation.response(
            "PushNotification",
            "application/json",
            Schemas.Response.SendNotification.ServiceUnavailable
          ),
        520 =>
          Operation.response(
            "PushNotification",
            "application/json",
            Schemas.Response.SendNotification.UnknownError
          )
      }
    }
  end

  def send(conn = %{body_params: %Schemas.Request.SendNotification.Deep.Data{} = params}, %{
        device_id: _device_id
      }) do
    json(conn, %{200 => :ok})
  end

  def send(conn = %{body_params: %Schemas.Request.SendNotification.Deep.Alert{} = params}, %{
        device_id: _device_id
      }) do
    json(conn, %{200 => :ok})
  end

  def send(conn = %{body_params: %Schemas.Request.SendNotification.Flat{} = params}, %{
        device_id: _device_id
      }) do
    json(conn, %{200 => :ok})
  end
end
