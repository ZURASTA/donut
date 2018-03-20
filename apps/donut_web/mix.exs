defmodule Donut.Web.Mixfile do
    use Mix.Project

    def project do
        [
            app: :donut_web,
            version: "0.0.1",
            build_path: "../../_build",
            config_path: "../../config/config.exs",
            deps_path: "../../deps",
            lockfile: "../../mix.lock",
            elixir: "~> 1.5",
            elixirc_paths: elixirc_paths(Mix.env),
            compilers: [:phoenix, :gettext] ++ Mix.compilers,
            start_permanent: Mix.env == :prod,
            aliases: aliases(),
            deps: deps()
        ]
    end

    # Configuration for the OTP application.
    #
    # Type `mix help compile.app` for more information.
    def application do
        [
            mod: { Donut.Web, [] },
            extra_applications: [:logger, :runtime_tools]
        ]
    end

    # Specifies which paths to compile per environment.
    defp elixirc_paths(:test), do: ["lib", "test/support"]
    defp elixirc_paths(_),     do: ["lib"]

    # Specifies your project dependencies.
    #
    # Type `mix help deps` for examples and options.
    defp deps do
        [
            { :phoenix, "~> 1.3.1" },
            { :phoenix_pubsub, "~> 1.0" },
            { :gettext, "~> 0.11" },
            { :cowboy, "~> 1.0" },
            { :absinthe, "~> 1.4" },
            { :absinthe_plug, "~> 1.4" },
            { :corsica, "~> 1.1" }
        ]
    end

    # Aliases are shortcuts or tasks specific to the current project.
    #
    # See the documentation for `Mix` for more info on aliases.
    defp aliases do
        []
    end
end
