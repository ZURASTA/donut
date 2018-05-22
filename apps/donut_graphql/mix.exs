defmodule Donut.GraphQL.Mixfile do
    use Mix.Project

    def project do
        [
            app: :donut_graphql,
            version: "0.1.0",
            build_path: "../../_build",
            config_path: "../../config/config.exs",
            deps_path: "../../deps",
            lockfile: "../../mix.lock",
            elixir: "~> 1.5",
            start_permanent: Mix.env == :prod,
            deps: deps()
        ]
    end

    # Run "mix help compile.app" to learn about applications.
    def application do
        [extra_applications: [:logger]]
    end

    # Run "mix help deps" to learn about dependencies.
    defp deps do
        [
            { :absinthe, "~> 1.4" },
            { :gobstopper_api, github: "ZURASTA/gobstopper", sparse: "apps/gobstopper_api" },
            { :sherbet_api, github: "ZURASTA/sherbet", sparse: "apps/sherbet_api" },
            { :gobstopper_service, github: "ZURASTA/gobstopper", sparse: "apps/gobstopper_service", only: [:dev, :test] },
            { :sherbet_service, github: "ZURASTA/sherbet", sparse: "apps/sherbet_service", only: [:dev, :test] },
            { :cake_service, github: "ZURASTA/cake", sparse: "apps/cake_service", only: [:dev, :test] }
        ]
    end
end
