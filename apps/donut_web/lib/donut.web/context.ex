defmodule Donut.Web.Context do
    @behaviour Plug

    def init(opts), do: opts

    def call(conn, opts) do
        case build_context(conn) do
            { :ok, context} -> Enum.reduce(opts[:forward], conn, &Plug.Conn.put_private(&2, &1, %{ context: context }))
            { :error, reason } -> Plug.Conn.send_resp(conn, 403, reason)
            _ -> Plug.Conn.send_resp(conn, 400, "Bad Request")
        end
    end

    defp build_context(conn) do
        { :ok, %{} }
        |> set_locale(Plug.Conn.get_req_header(conn, "accept-language"))
        |> set_identity(Plug.Conn.get_req_header(conn, "authorization"))
        |> set_api_key(Plug.Conn.get_req_header(conn, "x-api-key"))
    end

    defp set_locale(state, []), do: state
    defp set_locale({ :ok, state }, [locale|_]) do
        [lang|_] = String.split(locale, ",", parts: 2)
        [lang|_] = String.split(lang, ";")

        { :ok, Map.put(state, :locale, String.replace(lang, "-", "_") |> String.trim) }
    end
    defp set_locale(error, _), do: error

    defp set_identity(state, []), do: state
    defp set_identity({ :ok, state }, ["Bearer " <> token|_]) do
        case Gobstopper.API.Auth.verify(token) do
            nil -> { :ok, state }
            identity -> { :ok, state |> Map.put(:identity, identity) |> Map.put(:access_token, token) }
        end
    end
    defp set_identity(error, _), do: error

    defp set_api_key(state, []), do: state
    defp set_api_key({ :ok, state }, [key|_]) do
        { :ok, Map.put(state, :api_key, key) }
    end
    defp set_api_key(error, _), do: error
end
