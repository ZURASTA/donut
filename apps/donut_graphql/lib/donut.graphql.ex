defmodule Donut.GraphQL do
    use Absinthe.Schema
    import_types Donut.GraphQL.Result.Error
    import_types Donut.GraphQL.Result.InternalError
    import_types Donut.GraphQL.Auth
    import_types Donut.GraphQL.Identity

    query do
        import_fields :identity_queries
    end

    mutation do
        import_fields :auth_mutations
    end

    directive :debug do
        on [:field]
    end
end
