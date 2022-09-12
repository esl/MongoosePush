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
  def call(conn, opts) do
    stub_conn = %Plug.Conn{
      conn
      | adapter: {MongoosePushWeb.Plug.CastAndValidate.StubAdapter, %{}}
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
         conn = %{params: %{"alert" => _, "data" => _}},
         opts
       ) do
    new_opts =
      %OpenApiSpex.Reference{
        "$ref": "#/components/schemas/Request.SendNotification.Deep.MixedNotification"
      }
      |> update_schema(conn, opts)

    OpenApiSpex.Plug.CastAndValidate.call(conn, new_opts)
  end

  defp update_schema_and_do_call(
         conn = %{params: %{"data" => _}},
         opts
       ) do
    new_opts =
      %OpenApiSpex.Reference{
        "$ref": "#/components/schemas/Request.SendNotification.Deep.SilentNotification"
      }
      |> update_schema(conn, opts)

    OpenApiSpex.Plug.CastAndValidate.call(conn, new_opts)
  end

  defp update_schema_and_do_call(conn, opts) do
    new_opts =
      %OpenApiSpex.Reference{
        "$ref": "#/components/schemas/Request.SendNotification.Deep.AlertNotification"
      }
      |> update_schema(conn, opts)

    OpenApiSpex.Plug.CastAndValidate.call(conn, new_opts)
  end

  def update_schema(new_schema, conn, %{operation_id: operation_id} = opts) do
    new_operation_id = {operation_id, new_schema}

    spec_module = OpenApiSpex.Plug.PutApiSpec.spec_module(conn)
    {spec, operation_lookup} = cache().get(spec_module)

    unless operation_lookup[new_operation_id] do
      new_operation_lookup =
        operation_lookup[operation_id]
        |> update_in(
          [
            Access.key(:requestBody),
            Access.key(:content),
            "application/json",
            Access.key(:schema)
          ],
          fn %OpenApiSpex.Schema{oneOf: _listOfSchemas} -> new_schema end
        )
        |> then(&Map.put(operation_lookup, new_operation_id, &1))

      cache().put(spec_module, {spec, new_operation_lookup})
    end

    Map.put(opts, :operation_id, new_operation_id)
  end

  defp cache() do
    OpenApiSpex.Plug.Cache.adapter()
  end

  defp get_operation(
         _conn = %{private: %{phoenix_controller: controller, phoenix_action: action}}
       ) do
    controller.open_api_operation(action).operationId
  end
end
