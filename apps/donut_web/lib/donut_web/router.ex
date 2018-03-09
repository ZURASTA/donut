defmodule Donut.Web.Router do
    use Donut.Web, :router

    pipeline :api do
        plug :accepts, ["json"]
    end

    scope "/api", Donut.Web do
        pipe_through :api
    end
end
