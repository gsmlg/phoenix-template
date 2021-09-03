# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :gsmlg,
  namespace: GSMLG

config :gsmlg_web,
  namespace: GSMLGWeb,
  generators: [context_app: :gsmlg]

config :gsmlg_web, GSMLGWeb.Guardian,
  issuer: "gsmlg_web",
  secret_key: "hXlsH3NJCz8zrBZhoZABt+70YFn6F0pVtODnPK+SNIgWU0YEHbH0P29nADzbO/uy"

# Configures the endpoint
config :gsmlg_web, GSMLGWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lseCkwKom9khVDPObK7wBkNwWgBSt+gQinFvvFRc8W/w/+Nb9+EkMsi4KRzGy9gV",
  render_errors: [view: GSMLGWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: GSMLG.PubSub,
  live_view: [signing_salt: "sKQR1gLq"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
