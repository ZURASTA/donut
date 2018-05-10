defmodule Donut.GraphQL.Result.InternalError do
    @moduledoc """
      An internal error representation for result errors.

      * `:message` - Contains the presentable error message.
      * `:exception` - Contains the presentable exception module.
      * `:stacktrace` - Contains the presentable stacktrace from where the
      exception was raised/trown.
    """
    use Absinthe.Schema.Notation

    @type t :: %Donut.GraphQL.Result.InternalError{
        message: String.t,
        exception: String.t,
        stacktrace: String.t
    }

    defstruct [
        :message,
        :exception,
        :stacktrace
    ]

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

    @doc """
      Create an internal error struct to be returned as an InternalError object
      in GraphQL queries.

      **Note:** This should be called when the exception is caught.
    """
    @spec new(atom, term) :: Donut.GraphQL.Result.InternalError.t
    def new(type, exception) do
        [entry|_] = trace = System.stacktrace
        %Donut.GraphQL.Result.InternalError{
            message: "#{Exception.format_banner(type, exception)}\n    #{Exception.format_stacktrace_entry(entry)}",
            exception: inspect(exception),
            stacktrace: Exception.format_stacktrace(trace)
        }
    end
end
