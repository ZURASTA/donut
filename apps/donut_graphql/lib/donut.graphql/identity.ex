defmodule Donut.GraphQL.Identity do
    use Donut.GraphQL.Schema.Notation
    import_types Donut.GraphQL.Identity.Contact
    import_types Donut.GraphQL.Identity.Credential

    @desc "The verification status"
    enum :verification_status do
        value :unverified
        value :verified
    end

    @desc "An identity"
    object :identity do
        field :id, non_null(:id), description: "The unique ID of the identity"
        field :token, non_null(:string), description: "The access token that granted access to this identity"

        import_fields :credential_queries
        import_fields :contact_queries
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
                        identity -> { :ok, %{ id: identity, token: token } }
                    end
                _, %{ context: %{ identity: identity, access_token: token } } -> { :ok, %{ id: identity, token: token } }
                _, _ -> { :error, "Missing token" }
            end
        end
    end
end
