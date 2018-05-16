defmodule Donut.GraphQL.Identity do
    use Donut.GraphQL.Schema.Notation

    @desc "The type of credential"
    enum :credential_type do
        value :email
    end

    @desc "The verification status"
    enum :verification_status do
        value :unverified
        value :verified
    end

    @desc "The state of a given authentication credential"
    object :credential do
        field :type, non_null(:credential_type), description: "The type of credential"
        field :status, :verification_status, description: "The current verification status of the credential"
        field :presentable, :string, description: "The presentable information about the credential"
    end

    @desc """
    The collection of possible results from a credential request. If successful
    returns the `Credential` trying to be accessed, otherwise returns an error.
    """
    result :credential, [:credential]

    @desc "An identity"
    object :identity do
        field :id, non_null(:id), description: "The unique ID of the identity"
        field :token, non_null(:string), description: "The access token that granted access to this identity"

        @desc "The credentials associated with the identity"
        field :credentials, list_of(result(:credential)) do
            @desc "The type of credential to retrieve"
            arg :type, :credential_type

            @desc "The status of the credentials to retrieve"
            arg :status, :verification_status

            @desc """
            Whether to retrieve credentials that have been associated with the
            identity, or ones which have not.
            """
            arg :associated, :boolean

            resolve fn
                %{ token: token }, args, _ ->
                    case Gobstopper.API.Auth.all_credentials(token) do
                        { :ok, credentials } -> { :ok, filter_credentials(credentials, args) }
                        { :error, reason } -> { :ok, %Donut.GraphQL.Result.Error{ message: reason } }
                    end
            end
        end
    end

    defp filter_credentials(credentials, args = %{ associated: associated }) do
        filter_credentials(credentials, Map.delete(args, :associated))
        |> Enum.filter(fn
            %{ status: _, presentable: _ } -> associated
            _ -> !associated
        end)
    end
    defp filter_credentials(credentials, %{ type: type, status: status }) do
        Enum.find_value(credentials, [], fn
            { ^type, { ^status, presentable } } -> [%{ type: type, status: status, presentable: presentable }]
            _ -> false
        end)
    end
    defp filter_credentials(credentials, %{ type: type }) do
        Enum.find_value(credentials, [], fn
            { ^type, { :none, nil } } -> [%{ type: type }]
            { ^type, { status, presentable } } -> [%{ type: type, status: status, presentable: presentable }]
            _ -> false
        end)
    end
    defp filter_credentials(credentials, %{ status: status }) do
        Enum.reduce(credentials, [], fn
            { type, { ^status, presentable } }, acc -> [%{ type: type, status: status, presentable: presentable }|acc]
            _, acc -> acc
        end)
        |> Enum.reverse
    end
    defp filter_credentials(credentials, _) do
        Enum.map(credentials, fn
            { type, { :none, nil } } -> %{ type: type }
            { type, { status, presentable } } -> %{ type: type, status: status, presentable: presentable }
        end)
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
