defmodule Donut.GraphQL.Result.InternalError do
    @moduledoc """
      An internal error representation for result errors.

      * `:message` - Contains the presentable error message.
      * `:exception` - Contains the presentable exception module.
      * `:stacktrace` - Contains the presentable stacktrace from where the
      exception was raised/trown.
      * `:error_message` - The full error message that would have been displayed
      normally.
    """

    @type t :: %Donut.GraphQL.Result.InternalError{
        message: String.t,
        exception: String.t,
        stacktrace: String.t
    }

    defstruct [
        :message,
        :exception,
        :stacktrace,
        :error_message
    ]

    @doc """
      Create an internal error struct to be returned as an InternalError object
      in GraphQL queries.

      **Note:** This should be called when the exception is caught.
    """
    @spec new(atom, term) :: Donut.GraphQL.Result.InternalError.t
    def new(type, exception) do
        [entry|_] = trace = System.stacktrace
        stack = Exception.format_stacktrace(trace)
        banner = Exception.format_banner(type, exception)
        %Donut.GraphQL.Result.InternalError{
            message: "#{banner}\n    #{Exception.format_stacktrace_entry(entry)}",
            exception: inspect(exception),
            stacktrace: stack,
            error_message: "#{banner}\n#{stack}"
        }
    end
end
