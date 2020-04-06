defmodule MongoosePushWeb.APIv3.NotificationController do
  alias MongoosePushWeb.Schemas
  alias OpenApiSpex.{Operation, Schema}
  use MongoosePushWeb, :controller

  use MongoosePushWeb.Schemas

  @spec send_operation() :: Operation.t()
  def send_operation() do
    %Operation{
      tags: ["apiv3"],
      summary: "sends a push",
      description: "performs the sending of push notification",
      operationId: "APIv3.NotificationController.send",
      parameters: [
        Operation.parameter(:id, :path, :string, "Device ID", example: "f53453455", required: true)
      ],
      requestBody:
        Operation.request_body(
          "The push notification attributes",
          "application/json",
          %Schema{
            anyOf: [
              Schemas.Request.SendNotification.Deep.Alert,
              Schemas.Request.SendNotification.Deep.AlertAndData,
              Schemas.Request.SendNotification.Deep.Data
            ]
          },
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
end
