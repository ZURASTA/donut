defmodule Donut.GraphQL.Identity.Credential do
    use Donut.GraphQL.Schema.Notation

    @desc "The type of credential"
    enum :credential_type do
        value :email
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

    object :credential_queries do
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

    object :credential_mutations do
        @desc "Add or replace a credential for an identity"
        field :set_credential, type: result(:credential) do
            @desc "The email credential to associate with the identity"
            arg :email_credential, :email_credential

            resolve fn
                %{ token: token }, %{ email_credential: %{ email: email, password: pass } }, _ ->
                    case Gobstopper.API.Auth.Email.set(token, email, pass) do
                        :ok ->
                            case Gobstopper.API.Auth.Email.get(token) do
                                { :ok, { status, presentable } } -> { :ok, %{ type: :email, status: status, presentable: presentable } }
                                { :error, reason } -> { :ok, %Donut.GraphQL.Result.Error{ message: reason } }
                            end
                        { :error, reason } -> { :ok, %Donut.GraphQL.Result.Error{ message: reason } }
                    end
                _, %{}, _ -> { :error, "Missing credential" }
                _, _, _ -> { :error, "Only one credential can be specified" }
            end
        end
    end
end
