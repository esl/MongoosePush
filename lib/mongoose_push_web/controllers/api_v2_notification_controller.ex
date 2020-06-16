defmodule MongoosePushWeb.APIv2.NotificationController do
  alias MongoosePushWeb.Schemas
  alias OpenApiSpex.Operation
  use MongoosePushWeb, :controller

  use MongoosePushWeb.Schemas

  plug(MongoosePushWeb.Plug.CastAndValidate)

  @spec send_operation() :: Operation.t()
  def send_operation() do
    %Operation{
      tags: ["apiv2"],
      summary: "sends a push",
      deprecated: true,
      description: "performs the sending of push notification",
      operationId: "APIv2.NotificationController.send",
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
        500 =>
          Operation.response(
            "PushNotification",
            "application/json",
            Schemas.Response.SendNotification.GenericError
          )
      }
    }
  end

  def send(conn = %{body_params: params}, %{device_id: device_id}) do
    request = MongoosePushWeb.Protocols.RequestDecoder.decode(params)
    result = MongoosePush.Application.backend_module().push(device_id, request)
    {status, payload} = MongoosePush.API.V2.ResponseEncoder.to_status(result)

    conn
    |> Plug.Conn.put_status(status)
    |> json(payload)
  end
end
