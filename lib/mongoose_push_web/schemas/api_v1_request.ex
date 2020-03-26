defmodule APIv1Request do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "User",
    description: "A user of the app",
    type: :object,
    properties: %{
      service: %Schema{type: :string, description: "Push notification service", format: :string},
      body: %Schema{type: :string, description: "Body of the notification", format: :string},
      title: %Schema{type: :string, description: "Title of the notification", format: :string}
    },
    required: [:service, :body, :title],
    example: %{
      "service" => "apns",
      "body" => "A message from someone",
      "title" => "Notification title"
    }
  })
end
