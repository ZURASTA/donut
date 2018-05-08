defmodule Donut.GraphQL.Auth do
    use Absinthe.Schema.Notation

    @desc "An email authorization credential"
    input_object :email_credential do
        field :email, non_null(:string), description: "The user email"
        field :password, non_null(:string), description: "The password for this credential"
    end
end
