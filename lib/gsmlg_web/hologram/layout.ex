defmodule GsmlgWeb.Hologram.Layout do
  @moduledoc "Independent browser runtime with shared navigation and sidebar preferences."
  use Hologram.Component
  use Hologram.JS
  alias GsmlgWeb.Hologram.LeftMenu
  alias Hologram.UI.Runtime

  js_import(:synchronizeTheme, from: "../../../assets/js/theme.js")

  def init(_props, component, server) do
    theme = get_cookie(server, "gsmlg_theme", "sunshine")
    theme = if theme in ["sunshine", "moonlight"], do: theme, else: "sunshine"

    stylesheet =
      DuskmoonBundler.static_path(GsmlgWeb.Endpoint, "/assets/css/app.css", profile: :gsmlg)

    component
    |> put_state(theme: theme, stylesheet: stylesheet)
    |> put_action(:synchronize_theme)
  end

  def action(:synchronize_theme, _params, component) do
    JS.call(:synchronizeTheme, [])
    component
  end

  def template do
    ~HOLO"""
    <!DOCTYPE html>
    <html lang="en" data-theme={@theme}>
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Ctext x='4' y='25' font-family='sans-serif' font-size='28' font-weight='700' fill='currentColor'%3Ed.%3C/text%3E%3C/svg%3E" />
        <title>Browser-local state · DuskMoon Design</title>
        <link rel="stylesheet" href={@stylesheet} />
        <Runtime />
      </head>
      <body class="bg-surface text-on-surface min-h-screen">
        <a href="#main-content" class="design-skip-link">Skip to content</a>
        <div class="design-shell">
          <header id="design-appbar" class="appbar appbar-sticky appbar-primary design-appbar">
            <a href="/" class="appbar-brand"><span class="design-mark" aria-hidden="true">d.</span><span class="appbar-title">DuskMoon</span></a>
            <div class="appbar-trailing">
              <nav class="appbar-actions" aria-label="Main navigation">
                <a href="/" class="appbar-action">Overview</a>
                <a href="/guidelines" class="appbar-action">Guidelines</a>
                <a href="/components" class="appbar-action">Components</a>
                <a href="/use-cases" class="appbar-action bg-primary-container text-on-primary-container" aria-current="page">Use Cases</a>
              </nav>
              <a href="https://github.com/gsmlg/phoenix-template" class="appbar-action design-source-link">Source ↗</a>
            </div>
          </header>
          <div class="design-body">
            <LeftMenu cid="design-navigation" />
            <div class="design-workspace">
              <div class="design-topbar">
                <nav aria-label="Breadcrumb" class="design-breadcrumb"><a href="/">Design reference</a><span aria-hidden="true">/</span><span>Use Cases</span></nav>
              </div>
            <main id="main-content" tabindex="-1"><slot /></main>
            <footer class="design-footer"><span>DuskMoon design reference / Browser-local state</span><a href="/guidelines" class="design-text-link">Shared design rules</a></footer>
          </div>
          </div>
        </div>
      </body>
    </html>
    """
  end
end
