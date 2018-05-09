defmodule Donut.GraphQL.Auth do
    use Absinthe.Schema.Notation

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

    object :auth_mutations do
        @desc "Login into an identity"
        field :login, type: :session do
            @desc "The email credential of the identity"
            arg :email_credential, :email_credential

            resolve fn
                args = %{ email_credential: %{ email: email, password: password } }, env when map_size(args) == 1 ->
                    { :ok, %{ access_token: "access", refresh_token: "refresh" } }
                args, env ->
                    { :error, "Missing credential" }
            end
        end
    end
end
