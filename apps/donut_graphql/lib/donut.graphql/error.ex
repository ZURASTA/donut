defmodule Donut.GraphQL.Error do
    use Donut.GraphQL.Schema.Notation

    @desc """
    The collection of possible error results from a request. If
    successful returns `null`, otherwise returns an error.
    """
    result :error, []

    @desc "A generic error interface"
    interface :generic_error do
        @desc "The presentable error message"
        field :message, :string
    end

    @desc "A generic error message"
    object :error do
        @desc "The presentable error message"
        field :message, :string

        interface :generic_error

        is_type_of fn
            %Donut.GraphQL.Result.Error{} -> true
            _ -> false
        end
    end

    @desc "An internal server error"
    object :internal_error do
        @desc "The presentable error message"
        field :message, :string

        @desc "The presentable exception module"
        field :exception, :string

        @desc "The presentable stacktrace from where the exception occurred"
        field :stacktrace, :string

        interface :generic_error

        is_type_of fn
            %Donut.GraphQL.Result.InternalError{} -> true
            _ -> false
        end
    end
end
