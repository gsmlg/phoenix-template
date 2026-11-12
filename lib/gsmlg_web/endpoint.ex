defmodule GsmlgWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :gsmlg

  @session_options [
    store: :cookie,
    key: "_gsmlg_key",
    signing_salt: "gsmlg-session-salt",
    same_site: "Lax"
  ]

  socket("/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]
  )

  socket("/socket", GsmlgWeb.UserSocket, websocket: true)

  if code_reloading? do
    plug(Plug.Static,
      at: "/assets/css",
      from: {:gsmlg, "priv/static/assets/css"},
      only: ~w(app.css)
    )

    plug(DuskmoonBundler.DevServer, root: "assets", profile: :gsmlg)
  end

  plug(Plug.Static,
    at: "/",
    from: :gsmlg,
    gzip: true,
    only: GsmlgWeb.static_paths()
  )

  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(:secure_browser_headers)
  plug(Hologram.Router)
  plug(GsmlgWeb.Router)

  defp secure_browser_headers(conn, _opts) do
    Phoenix.Controller.put_secure_browser_headers(conn, %{"x-frame-options" => "SAMEORIGIN"})
  end
end
