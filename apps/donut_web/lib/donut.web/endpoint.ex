defmodule Donut.Web.Endpoint do
    use Phoenix.Endpoint, otp_app: :donut_web

    # Code reloading can be explicitly enabled under the
    # :code_reloader configuration of your endpoint.
    if code_reloading? do
        plug Phoenix.CodeReloader
    end

    plug Plug.RequestId
    plug Plug.Logger

    plug Corsica,
        origins: [~r{^https?://localhost(:\d+)?$}],
        allow_headers: [
            "origin",
            "content-type",
            "accept-language",
            "accept",
            "authorization",
            "x-api-key"
        ]

    plug Plug.Parsers,
        parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
        pass: ["*/*"],
        json_decoder: Poison

    plug Donut.Web.Context,
        forward: [:absinthe]

    plug if(Mix.env != :dev, do: Absinthe.Plug, else: Absinthe.Plug.GraphiQL),
        schema: Donut.GraphQL

    @doc """
      Callback invoked for dynamically configuring the endpoint.

      It receives the endpoint configuration and checks if
      configuration should be loaded from the system environment.
    """
    def init(_key, config) do
        if config[:load_from_system_env] do
            port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
            { :ok, Keyword.put(config, :http, [:inet6, port: port]) }
        else
            { :ok, config }
        end
    end
end
