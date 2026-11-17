defmodule GsmlgWeb.NavigationRoutesTest do
  use GsmlgWeb.ConnCase
  import Phoenix.LiveViewTest

  test "every sidebar destination is a distinct path without fragments or query selectors" do
    for section <- ~w(guidelines components use-cases) do
      paths = Enum.map(GsmlgWeb.Layouts.section_links(section), &elem(&1, 2))
      assert length(paths) == length(Enum.uniq(paths))

      for path <- paths do
        uri = URI.parse(path)
        assert is_nil(uri.fragment), "Sidebar destination must be a route: #{path}"
        assert is_nil(uri.query), "Sidebar destination must be a route: #{path}"
      end
    end
  end

  test "component routes render only their selected integration and highlight it", %{conn: conn} do
    for topic <- ~w(core elements phoenix react) do
      path = "/components/#{topic}"
      {:ok, view, _} = live(conn, path)
      assert has_element?(view, "section##{topic}")
      assert has_element?(view, "#design-left-menu a[href='#{path}'][aria-current='page']")

      for other <- ~w(core elements phoenix react) -- [topic] do
        refute has_element?(view, "section##{other}")
      end
    end
  end

  test "guideline topics have separate directly accessible content", %{conn: conn} do
    for {path, present, absent} <- [
          {"/guidelines/colors", "#token-examples", "#design-specification"},
          {"/guidelines/specification", "#design-specification", "#token-examples"}
        ] do
      {:ok, view, _} = live(conn, path)
      assert has_element?(view, present)
      refute has_element?(view, absent)
      assert has_element?(view, "#design-left-menu a[href='#{path}'][aria-current='page']")
    end
  end

  test "workflow routes render only their selected example", %{conn: conn} do
    topics = [
      {"workspace-settings", "workspace-settings"},
      {"records", "record-browser"},
      {"confirmation", "confirmation"},
      {"progress", "progress"}
    ]

    for {topic, id} <- topics do
      path = "/use-cases/#{topic}"
      {:ok, view, _} = live(conn, path)
      assert has_element?(view, "section##{id}")
      assert has_element?(view, "#design-left-menu a[href='#{path}'][aria-current='page']")

      for {_other_topic, other_id} <- topics -- [{topic, id}] do
        refute has_element?(view, "section##{other_id}")
      end

      refute has_element?(view, "#lifetime-title")
    end
  end
end
