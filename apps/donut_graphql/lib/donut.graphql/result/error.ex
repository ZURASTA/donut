defmodule Donut.GraphQL.Result.Error do
    @moduledoc """
      The base for result errors.

      * `:message` - Contains the presentable error message.
    """
    use Donut.GraphQL.Schema.Notation

    defstruct [:message]

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

    @desc """
    The collection of possible error results from a request. If
    successful returns `null`, otherwise returns an error.
    """
    result :error, []
end
