defmodule Donut.GraphQL.Auth do
    use Donut.GraphQL.Schema.Notation

    @desc "An email authorization credential"
    input_object :email_credential do
        field :email, non_null(:string), description: "The email for this credential"
        field :password, non_null(:string), description: "The password for this credential"
    end

    @desc "An identity session"
    object :session do
        field :access_token, non_null(:string), description: "An access token use to authenticate requests of an identity"
        field :refresh_token, non_null(:string), description: "A refresh token used manage the session"
    end

    @desc "The collection of possible results from a login request"
    result :login, [:session]

    object :auth_mutations do
        @desc "Login into an identity"
        field :login, type: result(:login) do
            @desc "The email credential of the identity"
            arg :email_credential, :email_credential

            resolve fn
                args = %{ email_credential: %{ email: email, password: pass } }, _ ->
                    case Gobstopper.API.Auth.Email.login(email, pass) do
                        { :ok, token } -> { :ok, %{ access_token: token, refresh_token: token } }
                        { :error, reason } ->  { :ok, %Donut.GraphQL.Result.Error{ message: reason } }
                    end
                %{}, _ ->
                    { :error, "Missing credential" }
                _, _ ->
                    { :error, "Only one credential can be specified" }
            end
        end
    end
end
