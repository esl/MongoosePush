defmodule MongoosePushWeb.APIv1Controller do
  alias MongoosePushWeb.Schemas
  alias OpenApiSpex.Operation
  use MongoosePushWeb, :controller

use MongoosePushWeb.Schemas

  @spec send_notification_operation() :: Operation.t()
  def send_notification_operation() do
    %Operation{
      tags: ["apiv1"],
      summary: "sends a push",
      description: "performs the sending of push notification",
      operationId: "APIv1Controller.send_notification",
      parameters: [
        Operation.parameter(:id, :path, :string, "Device ID", example: "f53453455", required: true)
      ],
      requestBody:
        Operation.request_body(
          "The push notification attributes",
          "application/json",
          Schemas.APIv1.Request.Push,
          required: true
        ),
      responses: %{
        200 => Operation.response("PushNotification", "application/json", Schemas.APIv1.Response.Push)
      }
    }
  end
end
