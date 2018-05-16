defmodule Donut.GraphQL.Identity do
    use Donut.GraphQL.Schema.Notation

    @desc "An identity"
    object :identity do
        field :id, non_null(:id), description: "The unique id of the identity"
    end

    @desc """
    The collection of possible results from an identity request. If successful
    returns the `Identity` trying to be accessed, otherwise returns an error.
    """
    result :identity, [:identity]

    object :identity_queries do
        @desc "Get details about an identity"
        field :identity, type: result(:identity) do
            @desc "The token granting access to the identity"
            arg :access_token, :string

            resolve fn
                %{ access_token: token }, _ ->
                    case Gobstopper.API.Auth.verify(token) do
                        nil ->  { :ok, %Donut.GraphQL.Result.Error{ message: "Invalid access token" } }
                        identity -> { :ok, %{ id: identity } }
                    end

                _, %{ context: %{ identity: identity } } ->
                    { :ok, %{ id: identity } }
            end
        end
    end
end
