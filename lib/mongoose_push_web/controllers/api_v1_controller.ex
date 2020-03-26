defmodule MongoosePushWeb.APIv1Controller do
  alias MongoosePushWeb.Schemas
  alias OpenApiSpex.Operation
  use MongoosePushWeb, :controller

use MongoosePushWeb.Schemas

  @spec handle_operation() :: Operation.t()
  def handle_operation() do
    %Operation{
      tags: ["apiv1"],
      summary: "sends a push",
      description: "performs the sending of push notification",
      operationId: "APIv1Controller.handle",
      parameters: [
        Operation.parameter(:id, :path, :string, "Device ID", example: "f53453455", required: true)
      ],
      requestBody:
        Operation.request_body(
          "The push notification attributes",
          "application/json",
          Schemas.APIv1Request,
          required: true
        ),
      responses: %{
        200 => Operation.response("PushNotification", "application/json", Schemas.APIv1Response)
      }
    }
  end
end
