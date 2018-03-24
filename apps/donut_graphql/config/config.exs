# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

if Mix.env in [:test, :dev] do
config :gobstopper_service,
    ecto_repos: [Gobstopper.Service.Repo]

config :guardian_db, GuardianDb,
    repo: Gobstopper.Service.Repo,
    schema_name: "tokens",
    sweep_interval: 120

config :sherbet_service,
    ecto_repos: [Sherbet.Service.Repo]
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
