import Config

config :gsmlg, Gsmlg.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "gsmlg_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :gsmlg, GsmlgWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "x2KKtgZ09R+tkr1nKiJqCBfaVPNBCFhsUvopCd82COii3ZqS13u4TQQcwfQULNNy",
  server: false

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
config :phoenix_live_view, enable_expensive_runtime_checks: true
