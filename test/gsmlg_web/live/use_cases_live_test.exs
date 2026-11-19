defmodule GsmlgWeb.UseCasesLiveTest do
  use GsmlgWeb.ConnCase
  import Phoenix.LiveViewTest

  test "settings validate, save a trimmed value, clear stale success, and cancel to the last save",
       %{
         conn: conn
       } do
    {:ok, view, _} = live(conn, ~p"/use-cases")

    view |> form("#profile-form", profile: %{name: " "}) |> render_submit()
    assert has_element?(view, "#profile-name-errors", "Use between 2 and 60 characters.")
    refute has_element?(view, "#saved-profile")

    view |> form("#profile-form", profile: %{name: "  Atlas team  "}) |> render_submit()
    assert has_element?(view, "#profile-name[value='Atlas team']")
    assert has_element?(view, "#saved-profile", "Atlas team")

    view |> form("#profile-form", profile: %{name: "A"}) |> render_change()
    refute has_element?(view, "#saved-profile")
    assert has_element?(view, "#profile-name-errors")

    view |> element("#cancel-settings") |> render_click()
    assert has_element?(view, "#profile-name[value='Atlas team']")
    refute has_element?(view, "#profile-name-errors")
    refute has_element?(view, "#saved-profile")
  end

  test "cancelling an unsaved draft restores the initial preview value", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/use-cases")
    view |> form("#profile-form", profile: %{name: "An unsaved draft"}) |> render_change()
    view |> element("#cancel-settings") |> render_click()
    assert has_element?(view, "#profile-name[value='Design workspace']")
  end

  test "search and status filter combine, clear inaccessible details, and recover from no results",
       %{
         conn: conn
       } do
    {:ok, view, _} = live(conn, ~p"/use-cases")
    assert has_element?(view, "#result-count", "3 workspaces")

    view |> element("#select-record-atlas") |> render_click()
    assert has_element?(view, "#selected-record", "Atlas workspace")
    assert has_element?(view, "#select-record-atlas[aria-pressed='true']")

    view |> form("#search-form", search: %{query: "relay", status: "draft"}) |> render_change()
    assert has_element?(view, "#result-count", "1 workspace")
    assert has_element?(view, "#workspace-records", "Relay workspace")
    refute has_element?(view, "#selected-record")

    view |> form("#search-form", search: %{query: "relay", status: "active"}) |> render_change()
    assert has_element?(view, "#empty-results", "No matching workspaces")
    refute has_element?(view, "#workspace-records")

    view |> element("#clear-filters") |> render_click()
    assert has_element?(view, "#result-count", "3 workspaces")
    assert has_element?(view, "#search-query[value='']")
    refute has_element?(view, "#empty-results")
    assert has_element?(view, "#search-status option[value='all'][selected]")
  end

  test "selection cannot reveal a filtered-out or unknown record", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/use-cases")
    view |> form("#search-form", search: %{query: "relay", status: "draft"}) |> render_change()
    render_click(view, "select_record", %{"id" => "atlas"})
    refute has_element?(view, "#selected-record")
    render_click(view, "select_record", %{"id" => "unknown"})
    refute has_element?(view, "#selected-record")
    view |> element("#select-record-relay") |> render_click()
    assert has_element?(view, "#selected-record", "Relay workspace")
  end

  test "removal requires confirmation and cancellation preserves the object", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/use-cases")
    render_click(view, "confirm_remove")
    refute has_element?(view, "#removed-item")

    view |> element("#ask-remove") |> render_click()
    assert has_element?(view, "dialog#confirm-panel", "Remove Weekly review?")
    view |> element("#cancel-remove") |> render_click()
    refute has_element?(view, "#confirm-panel")
    refute has_element?(view, "#removed-item")
    assert has_element?(view, "#ask-remove")

    view |> element("#ask-remove") |> render_click()
    view |> element("#confirm-remove") |> render_click()
    assert has_element?(view, "#removed-item", "Weekly review was removed")
    refute has_element?(view, "#ask-remove")
    render_click(view, "confirm_remove")
    render_click(view, "ask_remove")
    refute has_element?(view, "#confirm-panel")

    view |> element("#restore-item") |> render_click()
    assert has_element?(view, "#ask-remove")
    refute has_element?(view, "#removed-item")
    view |> element("#ask-remove") |> render_click()
    view |> element("#confirm-remove") |> render_click()
    assert has_element?(view, "#removed-item")
  end

  test "progress transitions are bounded, labelled, and resettable", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/use-cases")
    assert has_element?(view, "#job-status", "Ready to start")
    assert has_element?(view, "#demo-progress[aria-valuenow='0']")

    view |> element("#advance-progress") |> render_click()
    assert has_element?(view, "#demo-progress[aria-valuenow='25']")
    assert has_element?(view, "#job-status", "In progress")
    for _ <- 1..5, do: render_click(view, "advance")
    assert has_element?(view, "#demo-progress[aria-valuenow='100']")
    assert has_element?(view, "#advance-progress[disabled]")
    assert has_element?(view, "#job-status", "Complete")

    view |> element("#reset-progress") |> render_click()
    assert has_element?(view, "#demo-progress[aria-valuenow='0']")
    assert has_element?(view, "#job-status", "Ready to start")
    refute has_element?(view, "#advance-progress[disabled]")
  end

  test "source attribution and separate runtime examples are explicit", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/use-cases")
    assert has_element?(view, "a[href*='github.com/gsmlg-opt/sigma/blob/']")
    assert has_element?(view, "a[href*='memory_records_live.ex']")
    assert has_element?(view, "a[href*='host_services_live.ex']")
    assert has_element?(view, "a[href*='logs_jobs_live.ex']")
    assert has_element?(view, "a[href='/use-cases/session']")
    assert has_element?(view, "a[href='/hologram-demo']")
    assert render(view) =~ "All records are synthetic."
  end
end
