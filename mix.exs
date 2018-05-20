defmodule Donut.Mixfile do
    use Mix.Project

    def project do
        [
            apps_path: "apps",
            start_permanent: Mix.env == :prod,
            aliases: aliases(),
            deps: deps(),
            dialyzer: [plt_add_deps: :transitive],
            name: "Donut",
            source_url: "https://github.com/ZURASTA/donut",
            docs: [
                main: "donut",
                extras: [
                    "README.md": [filename: "donut", title: "Donut"],
                    "graphql.md": [filename: "graphql", title: "GraphQL"]
                ]
            ]
        ]
    end

    # Dependencies can be Hex packages:
    #
    #   {:mydep, "~> 0.3.0"}
    #
    # Or git/path repositories:
    #
    #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
    #
    # Type "mix help deps" for more examples and options.
    #
    # Dependencies listed here are available only for this project
    # and cannot be accessed from applications inside the apps folder
    defp deps do
        [
            { :ex_doc, "~> 0.18", only: :dev, runtime: false },
            { :simple_markdown, "~> 0.5.2", only: :dev, runtime: false },
            { :ex_doc_simple_markdown, "~> 0.2.1", only: :dev, runtime: false },
            { :simple_markdown_extension_blueprint, "~> 0.2", only: :dev, runtime: false },
            { :simple_markdown_extension_highlight_js, "~> 0.1.0", only: :dev, runtime: false },
            { :blueprint, "~> 0.3.1", only: :dev, runtime: false }
        ]
    end

    defp aliases do
        [docs: &build_docs/1]
    end

    defp build_docs(_) do
        System.cmd("mix", ["compile"], env: [{ "MIX_ENV", "prod" }])

        Mix.Tasks.Compile.run([])
        Mix.Tasks.Docs.run([])


        Application.put_env(:phoenix, :serve_endpoints, true, persistent: true)
        Application.ensure_all_started(:donut_web)

        { schema, 0 } = System.cmd("get-graphql-schema", [Donut.Web.Endpoint.static_url])
        File.write!("donut.graphql", schema)

        { _, 0 } = System.cmd("ruby", ["-rgraphql-docs", "-e", "GraphQLDocs.build filename: 'donut.graphql', base_url: '/donut/api', output_dir: 'doc/api'"])

        IO.puts "#{IO.ANSI.green}GraphQL API docs successfully generated#{IO.ANSI.reset}"
        IO.puts "#{IO.ANSI.green}View them at \"doc/api/index.html\".#{IO.ANSI.reset}"

        File.rm!("donut.graphql")
    end
end
