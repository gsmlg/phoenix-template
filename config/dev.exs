import Config

gsmlg_duskmoon_bundler_watcher = [
  name: Gsmlg.Assets.DuskmoonBundlerWatcher,
  root: "assets",
  watch_dirs: ["lib/gsmlg_web", "lib/gsmlg", "assets"],
  tailwind: true,
  tailwind_css: "assets/css/app.css",
  tailwind_outdir: "priv/static/assets/css",
  target: :es2022
]

config :gsmlg, Gsmlg.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "gsmlg_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :gsmlg, GsmlgWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "8l6zV9xtsh16NFn1KDKWZ/C3PjAb0Kx40AUWPb3oVtOFovTRUi1na8lRlFlTmEZl",
  watchers: [
    duskmoon_bundler:
      {Gsmlg.Assets.DuskmoonBundlerWatcher, :run, [gsmlg_duskmoon_bundler_watcher]}
  ]

config :gsmlg, :dev_routes, true
config :logger, :default_formatter, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  debug_attributes: true,
  enable_expensive_runtime_checks: true

config :gsmlg, GsmlgWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*\.po$",
      ~r"lib/gsmlg_web/(controllers|live|components|router)/.*\.(ex|heex)$"
    ]
  ]
