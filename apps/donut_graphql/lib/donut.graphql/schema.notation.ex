defmodule Donut.GraphQL.Schema.Notation do
    defmacro __using__(_options) do
        quote do
            use Absinthe.Schema.Notation, except: [resolve: 1]
            import Donut.GraphQL.Schema.Notation, only: [resolve: 1]
            import Donut.GraphQL.Result
        end
    end

    require Logger

    defmacro resolve(fun) do
        quote do
            Absinthe.Schema.Notation.resolve(&Donut.GraphQL.Schema.Notation.run(&1, &2, &3, unquote(fun)))
        end
    end

    defp resolver(_, args, env, fun) when is_function(fun, 2), do: fun.(args, env)
    defp resolver(parent, args, env, fun), do: fun.(parent, args, env)

    @doc false
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
