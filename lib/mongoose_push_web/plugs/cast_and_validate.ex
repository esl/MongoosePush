defmodule MongoosePushWeb.Plug.CastAndValidate do
  @behaviour Plug
  alias Plug.Conn

  @impl Plug
  def init(opts) do
    OpenApiSpex.Plug.CastAndValidate.init(opts)
  end

  @impl Plug
  def call(
        conn = %{private: %{open_api_spex: private_data}, params: %{"service" => _, "alert" => _}},
        opts = %{
          operation_id: operation_id,
          render_error: render_error
        }
      ) do
    OpenApiSpex.Plug.CastAndValidate.call(conn, opts)
  end

  def call(
        conn = %{private: %{open_api_spex: private_data}, params: %{"service" => _, "data" => _}},
        opts = %{
          operation_id: operation_id,
          render_error: render_error
        }
      ) do
    OpenApiSpex.Plug.CastAndValidate.call(conn, opts)
  end

  def call(
        conn = %{private: %{open_api_spex: private_data}, params: %{"service" => _}},
        opts = %{
          operation_id: operation_id,
          render_error: render_error
        }
      ) do
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
        fn %OpenApiSpex.Schema{oneOf: [h | _]} -> h end
      )

    OpenApiSpex.Plug.CastAndValidate.call(conn, opts)
  end

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

  def call(conn, opts) do
    OpenApiSpex.Plug.CastAndValidate.call(conn, opts)
  end
end
