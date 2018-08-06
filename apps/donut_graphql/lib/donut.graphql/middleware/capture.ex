defmodule Donut.GraphQL.Middleware.Capture do
    @moduledoc """
      An Absinthe middleware to capture fields from resolves result and place
      them into the context.

      A capture can take the form of `atom | { context_key :: atom, result_key :: atom }`
      and can be a list of captures to capture multiple values. Captured values
      will overwrite any previous values with the same name in the context.

        field :foo, type:  do
            resolve fn _, _ -> { :ok, %{ a: 1, b: 2, c: 3 } }
            end

            middleware Donut.GraphQL.Middleware.Capture, :a \# Adds the value for :a to the context
            middleware Donut.GraphQL.Middleware.Capture foo: :b \# Adds the value for :b to the context with name :foo
      end
    """

    @behaviour Absinthe.Middleware

    @impl Absinthe.Middleware
    def call(resolution = %{ value: value }, { key, capture }) when is_atom(capture) do
        case value do
            %{ ^capture => value } -> %{ resolution | context: Map.put(resolution.context, key, value) }
            _ -> resolution
        end
    end
    def call(resolution, captures) when is_list(captures), do: Enum.reduce(captures, resolution, &call(&2, &1))
    def call(resolution, capture), do: call(resolution, { capture, capture })
end
