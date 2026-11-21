defmodule GsmlgWeb.HomeLiveTest do
  use GsmlgWeb.ConnCase
  import Phoenix.LiveViewTest

  test "introduces the design layers and reference navigation", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "h1", "One design language.")

    for layer <- Gsmlg.DesignCatalog.layers() do
      assert has_element?(
               view,
               "#repository-#{layer.id} a[href='#{Gsmlg.DesignCatalog.source_url(layer)}']"
             )
    end

    assert has_element?(
             view,
             "#repositories a[href='https://github.com/duskmoon-dev/duskmoon-web']"
           )

    for path <- ["/", "/guidelines", "/components", "/use-cases"] do
      assert has_element?(view, "nav[aria-label='Main navigation'] a[href='#{path}']")
    end

    assert has_element?(view, "a[href='/'][aria-current='page']")
    assert has_element?(view, ".design-shell-home #home-page-header[phx-hook=PageHeader]")
    assert has_element?(view, "#home-page-navigation")
    refute has_element?(view, "#design-appbar")
    refute has_element?(view, "#design-left-menu")
    refute has_element?(view, "#counter")
  end

  test "introduction pages use an appbar and contextual left menu", %{conn: conn} do
    for {path, label, destination} <- [
          {~p"/guidelines", "Guidelines", "/guidelines/specification"},
          {~p"/components", "Components", "/components/react"},
          {~p"/use-cases", "Use Cases", "/use-cases/session"},
          {~p"/use-cases/session", "Use Cases", "/hologram-demo"}
        ] do
      {:ok, view, _html} = live(conn, path)
      assert has_element?(view, "#design-appbar nav a[aria-current='page']", label)
      assert has_element?(view, "#design-left-menu[aria-label='#{label} navigation']")
      assert has_element?(view, "#design-left-menu a[href='#{destination}']")
      refute has_element?(view, ".design-shell-home")
    end
  end
end
