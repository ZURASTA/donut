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

    @desc "An identity session"
    input_object :input_session do
        field :access_token, non_null(:string), description: "An access token use to authenticate requests of an identity"
        field :refresh_token, non_null(:string), description: "A refresh token used manage the session"
    end

    @desc """
    The collection of possible results from a login request. If successful
    returns the new `Session`, otherwise returns an error.
    """
    result :login, [:session]

    @desc """
    The collection of possible results from a login request. If successful
    returns the `Session` that was invalidated, otherwise returns an error.
    """
    result :logout, [:session]

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

        @desc "Logout from an identity"
        field :logout, type: result(:logout) do
            @desc "The session to logout from"
            arg :session, non_null(:input_session)

            resolve fn %{ session: session = %{ refresh_token: token } }, _ ->
                Gobstopper.API.Auth.logout(token)
                { :ok, session }
            end
        end
    end
end
