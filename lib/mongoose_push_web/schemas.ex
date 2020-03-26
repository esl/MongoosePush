defmodule MongoosePushWeb.Schemas do
  defmacro __using__(_) do
    quote do
      def open_api_operation(action),
        do: apply(__MODULE__, String.to_existing_atom("#{action}_operation"), [])
    end
  end
end
