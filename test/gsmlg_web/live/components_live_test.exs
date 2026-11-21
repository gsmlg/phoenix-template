defmodule GsmlgWeb.ComponentsLiveTest do
  use GsmlgWeb.ConnCase
  import Phoenix.LiveViewTest

  test "presents each integration with source, usage, and isolated React preview", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/components")

    for section <- ~w(core elements phoenix react) do
      assert has_element?(view, "section##{section}")
    end

    assert has_element?(view, "#elements-preview[phx-update='ignore'] el-dm-input")
    assert has_element?(view, "#elements-switch[label='Email summaries']")
    assert has_element?(view, "#react-component-preview[src='/previews/react'][title]")
    assert html =~ "@duskmoon-dev/elements"
    assert html =~ "@duskmoon-dev/components"

    assert has_element?(
             view,
             "#phoenix a[href='https://github.com/duskmoon-dev/duskmoon-web/tree/v2.0.0-rc.3/phoenix/apps/duskmoon_phoenix']"
           )
  end

  test "Core counter and Phoenix review have independent, resettable state", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components")

    view |> element("#core-add") |> render_click()
    view |> element("#core-add") |> render_click()
    assert has_element?(view, "#core-count", "2 items")

    view
    |> form("#component-label-form", preview: %{label: "Accessibility review"})
    |> render_change()

    assert has_element?(view, "#component-label-output", "Accessibility review")

    for _ <- 1..4, do: render_click(view, "preview-advance")
    render_click(view, "preview-advance")
    assert has_element?(view, "#component-progress[aria-valuenow='100']")
    assert has_element?(view, "#component-complete", "All four example review steps")
    assert has_element?(view, "#component-advance[disabled]")
    assert has_element?(view, "#core-count", "2 items")

    view |> element("#component-reset") |> render_click()
    assert has_element?(view, "#component-progress[aria-valuenow='0']")
    assert has_element?(view, "#component-label-output", "Release checklist")
    refute has_element?(view, "#component-complete")

    view |> element("#core-reset") |> render_click()
    assert has_element?(view, "#core-count", "0 items")
  end

  test "React document has a validated theme and does not start LiveSocket", %{conn: conn} do
    response = conn |> put_req_cookie("gsmlg_theme", "moonlight") |> get(~p"/previews/react")
    body = html_response(response, 200)

    assert body =~ ~s(lang="en" data-theme="moonlight")
    assert body =~ "react_preview"
    refute body =~ "assets/js/app.js"
    refute body =~ "csrf-token"

    response =
      build_conn() |> put_req_cookie("gsmlg_theme", "unknown") |> get(~p"/previews/react")

    assert html_response(response, 200) =~ ~s(data-theme="sunshine")
  end

  test "mounted React form validates its event payload before displaying it", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/react")
    hook = element(view, "#react-form-preview[phx-hook='MountReactForm'][phx-update='ignore']")

    for values <- [
          %{"name" => nil, "description" => ""},
          %{"name" => "   ", "description" => ""},
          %{"name" => "Project", "description" => String.duplicate("x", 201)}
        ] do
      render_hook(hook, "react-form-submit", values)
      assert_reply(view, %{error: _})
    end

    refute has_element?(view, "#react-form-result p")

    render_hook(hook, "react-form-submit", %{
      "name" => "  Library refresh  ",
      "description" => "  Update the sample forms.  "
    })

    assert_reply(view, %{ok: true})
    assert has_element?(view, "#react-form-result strong", "Library refresh")
    assert has_element?(view, "#react-form-result p", "Update the sample forms.")
  end
end
