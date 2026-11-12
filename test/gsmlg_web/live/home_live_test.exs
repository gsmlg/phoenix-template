defmodule GsmlgWeb.HomeLiveTest do
  use GsmlgWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Phoenix.SessionProcess

  setup %{conn: conn} do
    conn = get(conn, ~p"/")
    session_id = get_session(conn, :session_id)
    on_exit(fn -> SessionProcess.terminate(session_id) end)
    %{conn: conn, session_id: session_id}
  end

  test "renders and handles repeated interactions and reset", %{conn: conn} do
    {:ok, view, html} = live(conn)
    assert html =~ "Build your next workflow."
    assert has_element?(view, "#counter", "0")
    view |> element("#increment") |> render_click()
    view |> element("#increment") |> render_click()
    assert has_element?(view, "#counter", "2")
    view |> element("#reset") |> render_click()
    assert has_element?(view, "#counter", "0")
  end

  test "a fresh browser session does not inherit another counter", %{conn: conn} do
    {:ok, first, _} = live(conn)
    first |> element("#increment") |> render_click()
    second_conn = get(build_conn(), ~p"/")
    other_id = get_session(second_conn, :session_id)
    on_exit(fn -> SessionProcess.terminate(other_id) end)
    refute other_id == get_session(conn, :session_id)
    {:ok, second, _} = live(second_conn)
    assert has_element?(second, "#counter", "0")
  end

  test "refresh and another tab retain state for the same browser session", %{conn: conn} do
    {:ok, first, _} = live(conn)
    first |> element("#increment") |> render_click()
    {:ok, refreshed, _} = live(recycle(conn), ~p"/")
    assert has_element?(refreshed, "#counter", "1")
    refreshed |> element("#increment") |> render_click()
    assert eventually(fn -> has_element?(first, "#counter", "2") end)
  end

  test "expired state waits until the next interaction to be recreated", %{
    conn: conn,
    session_id: id
  } do
    {:ok, view, _} = live(conn)
    view |> element("#increment") |> render_click()
    assert :ok = SessionProcess.terminate(id)
    assert eventually(fn -> has_element?(view, "#session-expired") end)
    refute SessionProcess.started?(id)
    view |> element("#increment") |> render_click()
    assert has_element?(view, "#counter", "1")
    refute has_element?(view, "#session-expired")
  end

  defp eventually(check, attempts \\ 30)
  defp eventually(check, 0), do: check.()

  defp eventually(check, attempts) do
    if check.() do
      true
    else
      Process.sleep(10)
      eventually(check, attempts - 1)
    end
  end
end
