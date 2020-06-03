defmodule MongoosePushWeb.Plug.CastAndValidate do
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
  def call(conn = %{params: %{"service" => _, "alert" => _}}, opts = %{operation_id: _}) do
    OpenApiSpex.Plug.CastAndValidate.call(conn, opts)
  end

  @impl Plug
  def call(conn = %{params: %{"service" => _, "data" => _}}, opts = %{operation_id: _}) do
    OpenApiSpex.Plug.CastAndValidate.call(conn, opts)
  end

  @impl Plug
  def call(conn = %{params: %{"service" => _}}, opts = %{operation_id: _}) do
    update_schema_and_do_call(conn, opts)
  end

  @impl Plug
  def call(conn = %{params: %{"alert" => _}}, opts = %{operation_id: _}) do
    update_schema_and_do_call(conn, opts)
  end

  @impl Plug
  def call(conn = %{params: %{"data" => _}}, opts = %{operation_id: _}) do
    update_schema_and_do_call(conn, opts)
  end

  @impl Plug
  def call(
        conn = %{
          private: %{
            phoenix_controller: controller,
            phoenix_action: action,
            open_api_spex: private_data
          }
        },
        opts
      ) do
    operation =
      case private_data.operation_lookup[{controller, action}] do
        nil ->
          operationId = controller.open_api_operation(action).operationId
          operation = private_data.operation_lookup[operationId]

          operation_lookup =
            private_data.operation_lookup
            |> Map.put({controller, action}, operation)

          OpenApiSpex.Plug.Cache.adapter().put(
            private_data.spec_module,
            {private_data.spec, operation_lookup}
          )

          operation

        operation ->
          operation
      end

    if operation.operationId do
      call(conn, Map.put(opts, :operation_id, operation.operationId))
    else
      raise "operationId was not found in action API spec"
    end
  end

  @impl Plug
  def call(conn, opts) do
    OpenApiSpex.Plug.CastAndValidate.call(conn, opts)
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
    conn =
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
end
