defmodule MongoosePushWeb.APIv1.NotificationController do
  alias MongoosePushWeb.Schemas
  alias OpenApiSpex.Operation
  use MongoosePushWeb, :controller

  use MongoosePushWeb.Schemas

  @spec send_operation() :: Operation.t()
  def send_operation() do
    %Operation{
      tags: ["apiv1"],
      summary: "sends a push",
      description: "performs the sending of push notification",
      operationId: "APIv1.NotificationController.send",
      parameters: [
        Operation.parameter(:id, :path, :string, "Device ID", example: "f53453455", required: true)
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
          Operation.response("PushNotification", "application/json", Schemas.Response.SendNotification.PayloadOnly)
      }
    }
  end
end
