defmodule GsmlgWeb.Router do
  use GsmlgWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(Phoenix.SessionProcess.SessionId)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {GsmlgWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", GsmlgWeb do
    pipe_through(:browser)

    live("/", HomeLive, :index)
    live("/guidelines", GuidelinesLive, :index)
    live("/guidelines/colors", GuidelinesLive, :colors)
    live("/guidelines/specification", GuidelinesLive, :specification)
    live("/components", ComponentsLive, :index)
    live("/components/core", ComponentsLive, :core)
    live("/components/elements", ComponentsLive, :elements)
    live("/components/phoenix", ComponentsLive, :phoenix)
    live("/components/react", ComponentsLive, :react)
    live("/use-cases", UseCasesLive, :index)
    live("/use-cases/workspace-settings", UseCasesLive, :workspace_settings)
    live("/use-cases/records", UseCasesLive, :records)
    live("/use-cases/confirmation", UseCasesLive, :confirmation)
    live("/use-cases/progress", UseCasesLive, :progress)
    live("/use-cases/async-data", AsyncDataLive, :index)
    live("/use-cases/react-chat", ReactUseCaseLive, :chat)
    live("/use-cases/react-form", ReactUseCaseLive, :form)
    live("/use-cases/settings", SettingsLive, :general)
    live("/use-cases/settings/github", SettingsLive, :github)
    live("/use-cases/settings/appearance", SettingsLive, :appearance)
    live("/use-cases/session", SessionLive, :index)
    get("/guidelines/DESIGN.md", DesignController, :download)
    get("/previews/react", PreviewController, :react)
    get("/ui", DesignController, :legacy_ui)
  end
end
