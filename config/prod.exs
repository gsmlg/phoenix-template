import Config

config :gsmlg, GsmlgWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"
config :logger, level: :info

config :duskmoon_bundler, sourcemap: false
config :duskmoon_hologram, client_stacktraces: false, client_error_overlay: false

# TODO(upstream): duskmoon-dev/duskmoon-bundler#27
# WORKAROUND(upstream): development serves this CSS source directly; keep it out
# of the JS vendor scanner until mixed CSS/JS entries are supported there.
config :duskmoon_bundler, :gsmlg,
  entry: ["assets/js/app.js", "assets/js/react_preview.js", "assets/css/react_preview.css"]
