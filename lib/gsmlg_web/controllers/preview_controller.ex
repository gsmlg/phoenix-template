defmodule GsmlgWeb.PreviewController do
  use GsmlgWeb, :controller

  def react(conn, _params) do
    conn = fetch_cookies(conn)
    requested_theme = conn.req_cookies["gsmlg_theme"]
    theme = if requested_theme in ["sunshine", "moonlight"], do: requested_theme, else: "sunshine"

    stylesheet =
      DuskmoonBundler.static_path(GsmlgWeb.Endpoint, "/assets/css/app.css", profile: :gsmlg)
      |> escaped_attribute()

    react_stylesheet =
      DuskmoonBundler.static_path(GsmlgWeb.Endpoint, "/assets/css/react_preview.css",
        profile: :gsmlg
      )
      |> escaped_attribute()

    script =
      DuskmoonBundler.static_path(GsmlgWeb.Endpoint, "/assets/js/react_preview.js",
        profile: :gsmlg
      )
      |> escaped_attribute()

    html(conn, """
    <!DOCTYPE html>
    <html lang="en" data-theme="#{theme}">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Ctext x='4' y='25' font-family='sans-serif' font-size='28' font-weight='700' fill='currentColor'%3Ed.%3C/text%3E%3C/svg%3E" />
        <title>DuskMoon React preview</title>
        <link rel="stylesheet" href="#{react_stylesheet}">
        <link rel="stylesheet" href="#{stylesheet}">
        <script type="module" src="#{script}"></script>
      </head>
      <body class="min-h-screen bg-surface-container-low text-on-surface antialiased">
        <main class="mx-auto max-w-xl p-6">
          <div id="react-preview"><p role="status">Loading React preview...</p></div>
          <noscript>This interactive preview requires JavaScript.</noscript>
        </main>
      </body>
    </html>
    """)
  end

  defp escaped_attribute(value) do
    value |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
  end
end
