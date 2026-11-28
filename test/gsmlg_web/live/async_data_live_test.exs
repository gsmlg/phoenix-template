defmodule GsmlgWeb.AsyncDataLiveTest do
  use GsmlgWeb.ConnCase
  import Phoenix.LiveViewTest

  test "the initial HTTP response renders the page shell while data is loading", %{conn: conn} do
    html = conn |> get(~p"/use-cases/async-data") |> html_response(200)

    assert html =~ "Async data loading"
    assert html =~ ~s(id="async-workspace-loading")
    refute html =~ ~s(id="async-workspace-result")
  end

  test "live navigation renders loading, then data, and recovers from a failed request", %{
    conn: conn
  } do
    {:ok, overview, _} = live(conn, ~p"/use-cases")

    {:ok, view, html} =
      overview
      |> element("nav[aria-label='Use case sections'] a[href='/use-cases/async-data']")
      |> render_click()
      |> follow_redirect(conn, ~p"/use-cases/async-data")

    assert html =~ ~s(id="async-workspace-loading")
    assert has_element?(view, "a[href='/use-cases/async-data'][aria-current='page']")
    assert render_async(view, 5_000) =~ "Atlas workspace"

    assert view |> element("#async-workspace-simulate-failure") |> render_click() =~
             ~s(id="async-workspace-loading")

    assert render_async(view, 5_000) =~ "Could not load the workspace"
    assert has_element?(view, "#async-workspace-reload", "Retry")
    refute has_element?(view, "#async-workspace-result")

    view |> element("#async-workspace-reload") |> render_click()
    assert render_async(view, 5_000) =~ "Design systems"
    assert has_element?(view, "#async-workspace-result", "Atlas workspace")
    refute has_element?(view, "#async-workspace-error")
  end
end
