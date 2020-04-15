defmodule MongoosePushWeb.APIv1.NotificationController do
  alias MongoosePushWeb.Schemas
  alias OpenApiSpex.Operation
  use MongoosePushWeb, :controller

  use MongoosePushWeb.Schemas

  plug(OpenApiSpex.Plug.CastAndValidate)

  @spec send_operation() :: Operation.t()
  def send_operation() do
    %Operation{
      tags: ["apiv1"],
      summary: "sends a push",
      description: "performs the sending of push notification",
      operationId: "APIv1.NotificationController.send",
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
          Schemas.Request.SendNotification.Flat,
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

  def send(conn = %{body_params: %Schemas.Request.SendNotification.Flat{} = params}, %{
        device_id: device_id
      }) do
    json(conn, %{200 => :ok})
  end
end
