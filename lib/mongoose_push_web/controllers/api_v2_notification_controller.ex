defmodule MongoosePushWeb.APIv2.NotificationController do
  alias MongoosePushWeb.Schemas
  alias OpenApiSpex.Operation
  use MongoosePushWeb, :controller

  use MongoosePushWeb.Schemas

  plug(OpenApiSpex.Plug.CastAndValidate)

  def mongoose_push, do: Application.get_env(:mongoose_push, :mongoose_push)

  @spec send_operation() :: Operation.t()
  def send_operation() do
    %Operation{
      tags: ["apiv2"],
      summary: "sends a push",
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
    result = mongoose_push().push(device_id, params)
    {status, payload} = MongoosePush.API.V2.ResponseEncoder.to_status(result)

    conn
    |> Plug.Conn.put_status(status)
    |> json(payload)
  end
end
