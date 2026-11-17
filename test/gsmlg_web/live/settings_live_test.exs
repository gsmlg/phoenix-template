defmodule GsmlgWeb.SettingsLiveTest do
  use GsmlgWeb.ConnCase
  import Phoenix.LiveViewTest

  test "settings sections have direct routes and retain independent drafts", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/use-cases/settings")
    assert has_element?(view, "h1", "Workspace settings")
    assert has_element?(view, "#design-left-menu a[aria-current='page']", "Settings layout")
    refute has_element?(view, "#design-appbar [phx-hook='ThemeSwitcher']")

    view
    |> form("#workspace-general-form",
      profile: %{name: "Draft workspace", description: "Draft description"}
    )
    |> render_change()

    render_patch(view, ~p"/use-cases/settings/github")

    assert has_element?(
             view,
             "nav[aria-label='Workspace settings sections'] a[aria-current='page']",
             "GitHub integration"
           )

    view
    |> form("#workspace-github-form", integration: %{repository: "draft/repository"})
    |> render_change()

    render_patch(view, ~p"/use-cases/settings")
    assert has_element?(view, "#settings-display-name[value='Draft workspace']")
    assert has_element?(view, "#settings-description", "Draft description")
    render_patch(view, ~p"/use-cases/settings/github")
    assert has_element?(view, "#settings-repository[value='draft/repository']")
    render_patch(view, ~p"/use-cases/settings")
    assert has_element?(view, "#settings-section-title", "General")

    for path <- ~w(/use-cases/settings /use-cases/settings/github /use-cases/settings/appearance) do
      assert has_element?(view, "nav[aria-label='Workspace settings sections'] a[href='#{path}']")
    end
  end

  test "General validates, saves a trimmed profile and cancels to the last save", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/use-cases/settings")

    view
    |> form("#workspace-general-form",
      profile: %{name: " ", description: String.duplicate("x", 301)}
    )
    |> render_submit()

    assert has_element?(view, "#settings-display-name-errors", "Use between 2 and 60 characters.")
    assert has_element?(view, "#settings-description-errors", "Use no more than 300 characters.")
    refute has_element?(view, "#settings-feedback")

    view
    |> form("#workspace-general-form",
      profile: %{name: "  Atlas workspace  ", description: "  Shared guidance.  "}
    )
    |> render_submit()

    assert has_element?(view, "#settings-workspace-name", "Atlas workspace")
    assert has_element?(view, "#settings-display-name[value='Atlas workspace']")
    assert has_element?(view, "#settings-description", "Shared guidance.")
    assert has_element?(view, "#settings-feedback", "saved for this preview")

    view
    |> form("#workspace-general-form", profile: %{name: "A", description: "Unsaved description"})
    |> render_change()

    refute has_element?(view, "#settings-feedback")
    view |> element("#cancel-workspace-profile") |> render_click()
    assert has_element?(view, "#settings-display-name[value='Atlas workspace']")
    assert has_element?(view, "#settings-description", "Shared guidance.")
    refute has_element?(view, "#settings-display-name-errors")
  end

  test "integration preview validates and cancels without authorizing an account", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/use-cases/settings/github")
    assert has_element?(view, "#settings-section-title", "GitHub integration")

    view
    |> form("#workspace-github-form", integration: %{repository: "invalid"})
    |> render_submit()

    assert has_element?(view, "#settings-repository-errors", "Use owner/repository")
    assert has_element?(view, "#settings-repository[value='invalid']")

    view
    |> form("#workspace-github-form", integration: %{repository: "  duskmoon-dev/duskmoonui  "})
    |> render_submit()

    assert has_element?(view, "#settings-repository[value='duskmoon-dev/duskmoonui']")
    assert has_element?(view, "#settings-feedback", "No GitHub connection was made")

    view
    |> form("#workspace-github-form", integration: %{repository: "other/repository"})
    |> render_change()

    view |> element("#cancel-workspace-integration") |> render_click()
    assert has_element?(view, "#settings-repository[value='duskmoon-dev/duskmoonui']")
    refute has_element?(view, "#settings-feedback")
  end

  test "Appearance has immediate exclusive choices and fresh visits reset preview data", %{
    conn: conn
  } do
    {:ok, view, _} = live(conn, ~p"/use-cases/settings/appearance")

    assert has_element?(
             view,
             "#appearance-preference[phx-hook='AppearancePreference'][phx-update='ignore']"
           )

    for value <- ~w(default sunshine moonlight),
        do: assert(has_element?(view, "#appearance-preference button[value='#{value}']"))

    refute has_element?(view, "#workspace-general-form")
    render_patch(view, ~p"/use-cases/settings")

    view
    |> form("#workspace-general-form", profile: %{name: "Temporary name", description: ""})
    |> render_submit()

    {:ok, fresh, _} = live(conn, ~p"/use-cases/settings")
    assert has_element?(fresh, "#settings-display-name[value='Design workspace']")
  end
end
