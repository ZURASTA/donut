defmodule Donut.GraphQL.Schema.Notation do
    @moduledoc """
      Sets up the notations for building an Absinthe schema.
    """

    defmacro __using__(_options) do
        quote do
            use Absinthe.Schema.Notation, except: [resolve: 1]
            import Donut.GraphQL.Schema.Notation, only: [resolve: 1]
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
end
