defmodule GsmlgWeb.UILiveTest do
  use GsmlgWeb.ConnCase
  import Phoenix.LiveViewTest

  test "form rejects invalid input, saves valid input, then clears stale success", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/ui")
    view |> form("#profile-form", profile: %{name: " "}) |> render_submit()
    assert has_element?(view, "#profile-name-errors", "Use between 2 and 60 characters.")
    refute has_element?(view, "#saved-profile")
    view |> form("#profile-form", profile: %{name: "Ada"}) |> render_submit()
    assert has_element?(view, "#saved-profile", "Ada")
    view |> form("#profile-form", profile: %{name: "A"}) |> render_change()
    refute has_element?(view, "#saved-profile")
  end

  test "search can recover from an empty result", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/ui")
    view |> form("#search-form", search: %{query: "not-found"}) |> render_change()
    assert has_element?(view, "#empty-results")
    view |> form("#search-form", search: %{query: ""}) |> render_change()
    refute has_element?(view, "#empty-results")
    assert has_element?(view, "#example-results", "Phoenix LiveView")
  end

  test "cancel, confirm and restore remain repeatable", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/ui")
    render_click(view, "confirm_remove")
    refute has_element?(view, "#removed-item")
    view |> element("#ask-remove") |> render_click()
    view |> element("#cancel-remove") |> render_click()
    refute has_element?(view, "#confirm-panel")
    refute has_element?(view, "#removed-item")
    view |> element("#ask-remove") |> render_click()
    view |> element("#confirm-remove") |> render_click()
    assert has_element?(view, "#removed-item")
    view |> element("#restore-item") |> render_click()
    assert has_element?(view, "#ask-remove")
  end

  test "progress is bounded and resettable", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/ui")
    for _ <- 1..5, do: render_click(view, "advance")
    assert has_element?(view, "#demo-progress[aria-valuenow='100']")
    view |> element("#reset-progress") |> render_click()
    assert has_element?(view, "#demo-progress[aria-valuenow='0']")
  end
end
