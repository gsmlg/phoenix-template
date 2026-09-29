defmodule GsmlgWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :gsmlg

  @session_options [
    store: :cookie,
    key: "_gsmlg_key",
    signing_salt: "gsmlg-session-salt"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: false

  socket "/socket", GsmlgWeb.UserSocket, websocket: true

  plug Plug.Static,
    at: "/",
    from: :gsmlg,
    gzip: true,
    only: GsmlgWeb.static_paths()

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug GsmlgWeb.Router
end
