defmodule MongoosePushWeb.APIv3.NotificationController do
  alias MongoosePushWeb.Schemas
  alias OpenApiSpex.Operation
  use MongoosePushWeb, :controller

  use MongoosePushWeb.Schemas

  plug(MongoosePushWeb.Plug.CastAndValidate)

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
          %OpenApiSpex.Schema{
            oneOf: [
              MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertNotification,
              MongoosePushWeb.Schemas.Request.SendNotification.Deep.MixedNotification,
              MongoosePushWeb.Schemas.Request.SendNotification.Deep.SilentNotification
            ],
            additionalProperties: false
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

  def send(conn = %{body_params: params}, %{device_id: device_id}) do
    request = MongoosePushWeb.Protocols.RequestDecoder.decode(params)
    result = MongoosePush.Application.backend_module().push(device_id, request)
    {status, payload} = MongoosePush.API.V3.ResponseEncoder.to_status(result)

    conn
    |> Plug.Conn.put_status(status)
    |> json(payload)
  end
end
