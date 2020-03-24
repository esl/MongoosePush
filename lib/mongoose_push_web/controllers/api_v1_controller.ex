defmodule MongoosePushWeb.APIv1Controller do
  alias MongoosePushWeb.Schemas
  alias OpenApiSpex.Operation
  use MongoosePushWeb, :controller

  @spec open_api_operation(atom) :: Operation.t()
  def open_api_operation(action) do
    operation = String.to_existing_atom("#{action}_operation")
    apply(__MODULE__, operation, [])
  end

  @spec handle_operation() :: Operation.t()
  def handle_operation do
    %Operation{
      tags: ["api v1"],
      summary: "Send a push notification",
      description: "Sends a simple push notification based",
      operationId: "UserController.handle",
      parameters: [
        Operation.parameter(:id, :path, :string, "Device ID", example: "f53453455", required: true)
      ],
      requestBody:
        Operation.request_body("The push notification attributes", "application/json", Schemas.APIv1Request,
          required: true
        ),
      responses: %{
        200 => Operation.response("PushNotification", "application/json", Schemas.APIv1Response)
      }
    }
  end

  def handle(conn, params) do
    json(conn, %{ok: "git"})
  end
end

