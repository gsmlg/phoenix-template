# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# General application configuration
config :gsmlg,
  ecto_repos: [Gsmlg.Repo]

# Configures the endpoint
config :gsmlg, GsmlgWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pSvbnNLmHxY/I9Q/hOkyOWyFrdFWpUDs0uzjM9TK2uP9U7wd+A0wwVYMh8gQhlqH",
  render_errors: [view: GsmlgWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Gsmlg.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=esnext --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
