defmodule GsmlgWeb.DesignControllerTest do
  use GsmlgWeb.ConnCase
  import Phoenix.LiveViewTest

  test "downloads the exact canonical specification with a reproducible content hash", %{
    conn: conn
  } do
    conn = get(conn, ~p"/guidelines/DESIGN.md")
    source = File.read!(Path.expand("../../../DESIGN.md", __DIR__))
    assert response(conn, 200) == source
    assert get_resp_header(conn, "content-disposition") == ["attachment; filename=\"DESIGN.md\""]

    assert get_resp_header(conn, "x-design-spec-sha256") == [
             Base.encode16(:crypto.hash(:sha256, source), case: :lower)
           ]
  end

  test "guidelines render the same specification and download entry", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/guidelines")
    assert has_element?(view, "#download-design[href='/guidelines/DESIGN.md']")

    assert has_element?(
             view,
             "#design-specification",
             "Downstream Alignment and Specification Distribution"
           )

    assert has_element?(view, "a[aria-current='page'][href='/guidelines']")
  end

  test "legacy UI route redirects to use cases", %{conn: conn} do
    assert conn |> get(~p"/ui") |> redirected_to() == ~p"/use-cases"
  end

  test "React preview has an isolated runtime and validated theme cookie", %{conn: conn} do
    conn = conn |> put_req_cookie("gsmlg_theme", "moonlight") |> get(~p"/previews/react")
    body = html_response(conn, 200)
    assert body =~ ~s(data-theme="moonlight")
    assert body =~ "react_preview"
    refute body =~ "/assets/js/app"
    assert get_resp_header(conn, "x-frame-options") == ["SAMEORIGIN"]
  end
end
