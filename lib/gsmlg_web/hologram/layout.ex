defmodule GsmlgWeb.Hologram.Layout do
  use Hologram.Component
  alias Hologram.UI.Runtime

  def init(_props, component, server) do
    theme = get_cookie(server, "gsmlg_theme", "sunshine")
    theme = if theme in ["sunshine", "moonlight"], do: theme, else: "sunshine"

    stylesheet =
      DuskmoonBundler.static_path(GsmlgWeb.Endpoint, "/assets/css/app.css", profile: :gsmlg)

    put_state(component, theme: theme, stylesheet: stylesheet)
  end

  def template do
    ~HOLO"""
    <!DOCTYPE html>
    <html lang="en" data-theme={@theme}>
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Hologram · Gsmlg</title>
        <link rel="stylesheet" href={@stylesheet} />
        <Runtime />
      </head>
      <body class="bg-surface text-on-surface min-h-screen"><slot /></body>
    </html>
    """
  end
end
