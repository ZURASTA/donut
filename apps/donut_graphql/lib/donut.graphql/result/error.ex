defmodule Donut.GraphQL.Result.Error do
    @moduledoc """
      The base for result errors.

      * `:message` - Contains the presentable error message.
    """

    defstruct [:message]
end
