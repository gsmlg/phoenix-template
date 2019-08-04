# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :gsmlg,
  ecto_repos: [Gsmlg.Repo]

# Configures the endpoint
config :gsmlg, GsmlgWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pSvbnNLmHxY/I9Q/hOkyOWyFrdFWpUDs0uzjM9TK2uP9U7wd+A0wwVYMh8gQhlqH",
  render_errors: [view: GsmlgWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Gsmlg.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
