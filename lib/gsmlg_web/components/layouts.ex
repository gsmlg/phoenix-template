defmodule GsmlgWeb.Layouts do
  use GsmlgWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  slot :hero, required: true
  slot :inner_block, required: true

  def home(assigns) do
    assigns = assign(assigns, :navigation, navigation())

    ~H"""
    <a href="#main-content" class="design-skip-link">Skip to content</a>
    <div class="design-shell design-shell-home">
      <main id="main-content" tabindex="-1">
        <.dm_page_header
          id="home-page-header"
          nav_id="home-page-navigation"
          nav_label="Main navigation"
          class="design-home-header"
          nav_class="design-home-floating-nav"
        >
          <:menu
            :for={{id, label, path} <- @navigation}
            to={path}
            active={id == "overview"}
          >
            {label}
          </:menu>
          <:user_profile class="design-home-tools">
            <a href="https://github.com/gsmlg/phoenix-template" class="design-home-source">Source ↗</a>
            <.dm_theme_switcher />
          </:user_profile>
          {render_slot(@hero)}
        </.dm_page_header>
        {render_slot(@inner_block)}
      </main>
      <footer class="design-footer">
        <span>DuskMoon design reference <span aria-hidden="true">/</span> Built with Phoenix</span>
        <.link navigate={~p"/guidelines"} class="design-text-link">Shared rules. Intentional interfaces.</.link>
      </footer>
    </div>
    <.dm_flash_group flash={@flash} />
    """
  end

  attr :flash, :map, required: true
  attr :active, :string, default: "overview"
  attr :page, :string, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    assigns =
      assigns
      |> assign(:navigation, navigation())
      |> assign(:section_links, section_links(assigns.active))

    ~H"""
    <a href="#main-content" class="design-skip-link">Skip to content</a>
    <div class="design-shell">
      <.dm_appbar
        id="design-appbar"
        title="DuskMoon"
        title_to={~p"/"}
        class="appbar-primary design-appbar"
      >
        <:logo><span class="design-mark" aria-hidden="true">d.</span></:logo>
        <:menu
          :for={{id, label, path} <- @navigation}
          to={path}
          active={@active == id}
          class={@active == id && "bg-primary-container text-on-primary-container"}
        >
          {label}
        </:menu>
        <:user_profile>
          <a href="https://github.com/gsmlg/phoenix-template" class="appbar-action design-source-link">Source ↗</a>
          <.dm_theme_switcher />
        </:user_profile>
      </.dm_appbar>
      <div class="design-body">
        <.dm_left_menu
          :if={@active != "overview"}
          id="design-left-menu"
          class="design-left-menu"
          nav_label={section_title(@active) <> " navigation"}
        >
          <:title>{section_title(@active)}</:title>
          <:menu>
            <ul>
              <li :for={{id, label, path} <- @section_links}>
                <.link
                  href={path}
                  aria-current={if((@page || @active) == id, do: "page")}
                  class={(@page || @active) == id && "nested-menu-active"}
                >
                  {label}
                </.link>
              </li>
            </ul>
          </:menu>
        </.dm_left_menu>
        <div class="design-workspace">
          <div :if={@active != "overview"} class="design-topbar">
            <nav aria-label="Breadcrumb" class="design-breadcrumb">
              <.link navigate={~p"/"}>Design reference</.link>
              <span aria-hidden="true">/</span><span>{section_title(@active)}</span>
            </nav>
          </div>
          <main id="main-content" tabindex="-1">{render_slot(@inner_block)}</main>
          <footer class="design-footer">
            <span>DuskMoon design reference <span aria-hidden="true">/</span> Built with Phoenix</span>
            <.link navigate={~p"/guidelines"} class="design-text-link">Shared rules. Intentional interfaces.</.link>
          </footer>
        </div>
      </div>
    </div>
    <.dm_flash_group flash={@flash} />
    """
  end

  defp navigation do
    [
      {"overview", "Overview", ~p"/"},
      {"guidelines", "Guidelines", ~p"/guidelines"},
      {"components", "Components", ~p"/components"},
      {"use-cases", "Use Cases", ~p"/use-cases"}
    ]
  end

  defp section_links("guidelines") do
    [
      {"guidelines", "Introduction", ~p"/guidelines"},
      {"tokens", "Semantic colors", ~p"/guidelines#token-examples"},
      {"specification", "Design specification", ~p"/guidelines#design-specification"}
    ]
  end

  defp section_links("components") do
    [
      {"components", "Introduction", ~p"/components"},
      {"core", "Core CSS", ~p"/components#core"},
      {"elements", "Web Components", ~p"/components#elements"},
      {"phoenix", "Phoenix", ~p"/components#phoenix"},
      {"react", "React", ~p"/components#react"}
    ]
  end

  defp section_links("use-cases") do
    [
      {"use-cases", "Introduction", ~p"/use-cases"},
      {"settings", "Workspace settings", ~p"/use-cases#workspace-settings"},
      {"records", "Record browser", ~p"/use-cases#record-browser"},
      {"confirmation", "Confirmation", ~p"/use-cases#confirmation"},
      {"progress", "Progress", ~p"/use-cases#progress"},
      {"session", "Session state", ~p"/use-cases/session"},
      {"hologram", "Browser-local state", ~p"/hologram-demo"}
    ]
  end

  defp section_links(_), do: []

  defp section_title(active) do
    Enum.find_value(navigation(), "Overview", fn {id, title, _} ->
      if id == active, do: title
    end)
  end
end
