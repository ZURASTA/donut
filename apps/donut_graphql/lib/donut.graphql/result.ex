defmodule Donut.GraphQL.Result do
    @moduledoc """
      Create a result type for GraphQL queries.

      These result types standardize the result interfaces and error behaviour
      that the client with interact with.

      ## Example
        \# Declare a result with only one custom type
        result :new_type, [:foo]

        \# Declare a result with multiple custom types
        result :new_type, [:foo, :bar], fn
            %Foo{}, _ -> :foo
            %Bar{}, _ -> :bar
        end

        \# Setting up your query
        field :foo, type: result(:new_type) do
            \# ...
        end
    """

    @type resolver :: (any, Absinthe.Resolution.t -> atom | nil)

    @doc """
      Get the name for a result type.
    """
    @spec result(atom) :: atom
    def result(name), do: String.to_atom(to_string(name) <> "_result")

    @doc """
      Create a result type that can represent a custom type.

      See `result/3` for more details.
    """
    @spec result(atom, [atom]) :: Macro.t
    defmacro result(name, types = [type]) do
        quote do
            result(unquote(name), unquote(types), fn _, _ -> unquote(type) end)
        end
    end
    defmacro result(name, []) do
        quote do
            result(unquote(name), [], nil)
        end
    end
    defmacro result(name, types) do
        quote do
            result(unquote(name), unquote(types), fn value, env ->
                Donut.GraphQL.Result.type_resolver(value, env, unquote(types))
            end)
        end
    end

    @doc """
      Create a result type that can represent a custom type

      The `name` field should be the name used to refer to this new result type.

      The `types` field should be list of custom types to associate with this
      result type.

      The `resolver` is a function that should return the type for the given
      object. For more details see `Absinthe.Schema.Notation.resolve_type/1`.
    """
    @spec result(atom, [atom], resolver) :: Macro.t
    defmacro result(name, types, resolver) do
        quote do
            union unquote(result(name)) do
                types unquote(types ++ [:error, :internal_error])

                resolve_type &Donut.GraphQL.Result.get_type(&1, &2, unquote(resolver))
            end
        end
    end

    @doc false
    @spec type_resolver(any, Absinthe.Resolution.t, [atom]) :: atom | nil
    def type_resolver(value, %{ schema: schema }, types) do
        Enum.find_value(types, fn type ->
            case Absinthe.Schema.lookup_type(schema, type) do
                %{ is_type_of: resolves } when is_function(resolves) ->
                    if resolves.(value) do
                        type
                    else
                        false
                    end
                _ -> false
            end
        end)
    end

    @doc false
    @spec get_type(any, Absinthe.Resolution.t, resolver) :: atom | nil
    def get_type(%Donut.GraphQL.Result.Error{}, _, _), do: :error
    def get_type(%Donut.GraphQL.Result.InternalError{}, _, _), do: :internal_error
    def get_type(object, env, resolver) when is_function(resolver), do: resolver.(object, env)
end
