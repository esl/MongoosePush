defmodule MongoosePushWeb.Plug.NewCastAndValidate.StubAdapter do
  def send_resp(payload, _status, _headers, _body) do
    {:ok, nil, payload}
  end
end

defmodule MongoosePushWeb.Plug.NewCastAndValidate do
  @moduledoc """
  Module plug that serves as a wrapper for OpenApiSpex.Plug.CastAndValidate plug,
  to overcome difficulties with proper message validating. For more details,
  please refer to update_schema_and_do_call/2 function comment.
  """
  @behaviour Plug

  @impl Plug
  def init(opts) do
    OpenApiSpex.Plug.CastAndValidate.init(opts)
  end

  @impl Plug
  def call(conn, opts) do
    adapter = conn.adapter

    stub_conn = %Plug.Conn{
      conn
      | adapter: {MongoosePushWeb.Plug.NewCastAndValidate.StubAdapter, %{}}
    }

    # Just a dry run with stub adapter so that response can't be sent
    result = OpenApiSpex.Plug.CastAndValidate.call(stub_conn, opts)

    # Now we run the plug on original, unmodified conn, but with conditional schema change
    if result.status == 422 do
      update_schema_and_do_call(conn, Map.put(opts, :operation_id, get_operation(conn)))
    else
      OpenApiSpex.Plug.CastAndValidate.call(conn, opts)
    end
  end

  # When OpenApiSpex matches incoming request to schema defined as `oneOf: [%Reference{}]`,
  # and the request matches more than one alternative schema, it likes to throw misleading error
  # "Failed to cast value to one of: [] (no schemas provided)", instead of something more meaningful.
  # Here we avoid it by manual modification of the pattern the request is matched against,
  # so the framework can serve us as expected.
  defp update_schema_and_do_call(
         conn = %{params: %{"data" => _}},
         opts = %{operation_id: operation_id}
       ) do
    new_schema = %OpenApiSpex.Reference{
      "$ref": "#/components/schemas/Request.SendNotification.Deep.SilentNotification"
    }

    conn
    |> update_schema(operation_id, new_schema)
    |> OpenApiSpex.Plug.CastAndValidate.call(opts)
  end

  defp update_schema_and_do_call(conn, opts = %{operation_id: operation_id}) do
    new_schema = %OpenApiSpex.Reference{
      "$ref": "#/components/schemas/Request.SendNotification.Deep.AlertNotification"
    }

    conn
    |> update_schema(operation_id, new_schema)
    |> OpenApiSpex.Plug.CastAndValidate.call(opts)
  end

  defp update_schema(conn, operation_id, new_schema) do
    Kernel.update_in(
      conn,
      [
        Access.key(:private),
        :open_api_spex,
        :operation_lookup,
        operation_id,
        Access.key(:requestBody),
        Access.key(:content),
        "application/json",
        Access.key(:schema)
      ],
      fn %OpenApiSpex.Schema{oneOf: _listOfSchemas} -> new_schema end
    )
  end

  def get_operation(
        conn = %{
          private: %{
            phoenix_controller: controller,
            phoenix_action: action
          }
        }
      ) do
    operationId = controller.open_api_operation(action).operationId
  end
end
