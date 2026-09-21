defmodule MongoosePushWeb.Schemas.Request.SendNotification.Deep.Common.Data do
  require OpenApiSpex
  alias MongoosePushWeb.Schemas.Request.SendNotification.Deep

  OpenApiSpex.schema(%{
    title: "Request.SendNotification.Deep.Common.Data",
    description: """
    Custom key-value data sent to the target device, for example as a JMI payload.
    See the [HTTP API guide](https://github.com/esl/MongoosePush/blob/master/guides/http_api.md#jmi-call-notifications) for the exact JMI format.
    """,
    type: :object,
    example: Deep.data()[:example]["data"],
    additionalProperties: nil
  })
end
