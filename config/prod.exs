import Config

config :gsmlg, GsmlgWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"
config :logger, level: :info

config :duskmoon_bundler, sourcemap: false
config :duskmoon_hologram, client_stacktraces: false, client_error_overlay: false
