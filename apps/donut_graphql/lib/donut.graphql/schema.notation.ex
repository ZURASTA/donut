defmodule Donut.GraphQL.Schema.Notation do
    defmacro __using__(_options) do
        quote do
            use Absinthe.Schema.Notation, except: [resolve: 1]
            import Donut.GraphQL.Schema.Notation, only: [resolve: 1]
            import Donut.GraphQL.Result
        end
    end

    require Logger

    defmacro resolve(fun = { :fn, _, [{ :->, _, [args, _] }|_] }) when length(args) == 2 do
        quote do
            Absinthe.Schema.Notation.resolve(&Donut.GraphQL.Schema.Notation.resolver(&1, &2, unquote(fun)))
        end
    end
    defmacro resolve(fun = { :fn, _, [{ :->, _, [args, _] }|_] }) when length(args) == 3 do
        quote do
            Absinthe.Schema.Notation.resolve(&Donut.GraphQL.Schema.Notation.resolver(&1, &2, &3, unquote(fun)))
        end
    end

    @doc false
    def resolver(args, env = %{ definition: %{ directives: directives } }, fun) do
        run(args, env, &(fun.(&1, &2)))
    end

    @doc false
    def resolver(parent, args, env = %{ definition: %{ directives: directives } }, fun) do
        run(args, env, &(fun.(parent, &1, &2)))
    end

    defp run(args, env = %{ definition: %{ directives: directives } }, fun) do
        if Enum.any?(directives, fn
            %{ schema_node: %{ identifier: :debug } } -> true
            _ -> false
        end) do
            try do
                fun.(args, env)
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
            fun.(args, env)
        end
    end
end
