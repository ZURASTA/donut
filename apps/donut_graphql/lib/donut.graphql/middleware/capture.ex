defmodule Donut.GraphQL.Middleware.Capture do
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
