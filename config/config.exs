import Config

config :gsmlg,
  ecto_repos: [Gsmlg.Repo],
  generators: [timestamp_type: :utc_datetime]

config :gsmlg, GsmlgWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [formats: [html: GsmlgWeb.ErrorHTML, json: GsmlgWeb.ErrorJSON], layout: false],
  pubsub_server: Gsmlg.PubSub,
  live_view: [signing_salt: "gsmlg-template-salt"]

config :phoenix_live_view, root_tag_attribute: "phx-r"

config :duskmoon_bundler,
  resolve_dirs: ["node_modules", "deps"],
  target: :es2022,
  sourcemap: :inline

config :duskmoon_bundler, :gsmlg,
  entry: "assets/js/app.js",
  outdir: "priv/static/assets",
  root: "assets",
  asset_url_prefix: "/assets",
  tailwind: [
    css: "assets/css/app.css",
    sources: [
      %{base: "lib/gsmlg_web", pattern: "**/*.{ex,heex}"},
      %{base: "lib/gsmlg", pattern: "**/*.{ex,heex}"},
      %{base: "deps/phoenix_duskmoon/lib/phoenix_duskmoon", pattern: "**/*.{ex,heex}"},
      %{base: "assets", pattern: "**/*.{js,css}"}
    ]
  ],
  server: [prefix: "/assets", watch_dirs: ["lib/gsmlg_web", "lib/gsmlg", "assets"]]

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
