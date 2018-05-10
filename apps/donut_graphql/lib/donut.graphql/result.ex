defmodule Donut.GraphQL.Result do
    def result(name), do: String.to_atom(to_string(name) <> "_result")

    defmacro result(name, types = [type|_]) do
        quote do
            result(unquote(name), unquote(types), fn _, _ -> unquote(type) end)
        end
    end
    defmacro result(name, []) do
        quote do
            result(unquote(name), [], nil)
        end
    end

    defmacro result(name, types, resolver) do
        quote do
            union unquote(result(name)) do
                types unquote(types ++ [])

                resolve_type &Donut.GraphQL.Result.get_type(&1, &2, unquote(resolver))
            end
        end
    end

    def get_type(object, env, resolver) when is_function(resolver), do: resolver.(object, env)
end
