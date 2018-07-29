defmodule Donut.GraphQL.Schema.Notation do
    @moduledoc """
      Sets up the notations for building an Absinthe schema.
    """

    defmacro __using__(_options) do
        quote do
            use Absinthe.Schema.Notation, except: [resolve: 1]
            import Donut.GraphQL.Schema.Notation, only: [
                resolve: 1,
                mutable: 3, mutable: 4,
                immutable: 1, immutable: 2,
                mutable_object: 2, mutable_object: 3,
                mutable_interface: 2, mutable_interface: 3
            ]
            import Donut.GraphQL.Result
        end
    end

    require Logger

    @type parent :: map
    @type args :: map
    @type env :: Absinthe.Resolution.t
    @type result :: { :ok, any } | { :error, any }
    @type resolver :: (args, env -> result) | (parent, args, env -> result)

    @doc false
    @spec resolve(resolver) :: Macro.t
    defmacro resolve(fun) do
        quote do
            Absinthe.Schema.Notation.resolve(&Donut.GraphQL.Schema.Notation.run(&1, &2, &3, unquote(fun)))
        end
    end

    @spec resolver(parent, args, env, resolver) :: result
    defp resolver(_, args, env, fun) when is_function(fun, 2), do: fun.(args, env)
    defp resolver(parent, args, env, fun), do: fun.(parent, args, env)

    @doc false
    @spec run(parent, args, env, resolver) :: result
    def run(parent, args, env = %{ definition: %{ directives: directives } }, fun) do
        if Enum.any?(directives, fn
            %{ schema_node: %{ identifier: :debug } } -> true
            _ -> false
        end) do
            try do
                resolver(parent, args, env, fun)
            rescue
                exception ->
                    err = Donut.GraphQL.Result.InternalError.new(:error, exception)
                    Logger.error(err.error_message)

                    { :ok, err }
            catch
                type, value when type in [:exit, :throw] ->
                    err = Donut.GraphQL.Result.InternalError.new(type, value)
                    Logger.error(err.error_message)

                    { :ok, err }
            end
        else
            resolver(parent, args, env, fun)
        end
    end

    defmacro immutable(_attrs \\ [], _block), do: raise "Must be used inside a mutable object"

    defmacro mutable(type, name, attrs \\ [], block) do
        { mutable_body, immutable } = Macro.prewalk(block, nil, fn
            { :immutable, context, body }, _ ->
                field = quote do
                    field :immutable, non_null(unquote(name)), description: unquote("The immutable #{String.replace(to_string(name), "_", " ")} fields")
                end
                { field, { type, context, [name|body] } }
            node, acc -> { node, acc }
        end)

        quote do
            description = @desc
            unquote(immutable)

            @desc description
            unquote(type)(unquote(String.to_atom("mutable_#{to_string(name)}")), unquote(attrs), unquote(mutable_body))
        end
    end

    defmacro mutable_object(name, attrs \\ [], block) do
        quote do
            mutable(:object, unquote(name), unquote(attrs), unquote(block))
        end
    end

    defmacro mutable_interface(name, attrs \\ [], block) do
        quote do
            mutable(:interface, unquote(name), unquote(attrs), unquote(block))
        end
    end
end
