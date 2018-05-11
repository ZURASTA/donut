defmodule Donut.GraphQL do
    use Absinthe.Schema
    import_types Donut.GraphQL.Result.Error
    import_types Donut.GraphQL.Result.InternalError
    import_types Donut.GraphQL.Auth

    query do
    end

    mutation do
        import_fields :auth_mutations
    end

    directive :debug do
        on [:field]
    end
end
