defmodule GsmlgWeb.Hologram.LeftMenu do
  use Hologram.Component
  use Hologram.JS

  prop(:page_mounted?, :boolean, from_context: {Hologram.Runtime, :page_mounted?})

  def init(_props, component, _server) do
    items =
      for {id, label, path, icon} <- GsmlgWeb.Layouts.section_links("use-cases") do
        icon_paths =
          Regex.scan(~r/\bd="([^"]+)"/, PhoenixDuskmoon.Component.Icon.Icons.get_mdi_svg(icon),
            capture: :all_but_first
          )
          |> List.flatten()

        %{id: id, label: label, path: path, icon_paths: icon_paths}
      end

    component
    |> put_state(collapsed: false, items: items)
    # Server-rendered components restore browser preferences after mounting.
    |> put_action(:restore)
  end

  def action(:restore, _params, component) do
    collapsed =
      JS.eval("""
      (() => {
        try { return localStorage.getItem("gsmlg.navigation.collapsed") === "true"; }
        catch { return false; }
      })()
      """)

    put_state(component, :collapsed, collapsed)
  end

  def action(:toggle, _params, component) do
    collapsed = !component.state.collapsed

    JS.exec("""
    try { localStorage.setItem("gsmlg.navigation.collapsed", "#{collapsed}"); }
    catch { /* Persistence is optional; the current page remains usable. */ }
    """)

    put_state(component, :collapsed, collapsed)
  end

  def template do
    ~HOLO"""
    <nav id="design-left-menu" class="design-left-menu" aria-label="Use Cases navigation" data-collapsed={if(@collapsed, do: "true", else: "false")}>
      <div id="design-left-menu-scroll" data-left-menu-scroll>
        <ul class="nested-menu">
          <li class="nested-menu-title">Use Cases</li>
          {%for item <- @items}
            <li>
              <a href={item.path} aria-label={item.label} aria-current={if(item.id == "hologram", do: "page", else: nil)} class={if(item.id == "hologram", do: "nested-menu-active", else: "")} title={item.label} interestfor={"design-menu-#{item.id}-tooltip"} aria-describedby={"design-menu-#{item.id}-tooltip"} style={"anchor-name: --design-menu-#{item.id}"}>
                <svg viewBox="0 0 24 24" fill="currentColor" class="size-5 shrink-0" aria-hidden="true">
                  {%for path <- item.icon_paths}<path d={path} />{/for}
                </svg>
                <span data-left-menu-label>{item.label}</span>
              </a>
              <span id={"design-menu-#{item.id}-tooltip"} role="tooltip" popover="hint" class="tooltip tooltip-right" style={"position-anchor: --design-menu-#{item.id}"}>{item.label}</span>
            </li>
          {/for}
        </ul>
      </div>
      <button type="button" data-left-menu-toggle class="btn btn-ghost btn-square" aria-controls="design-left-menu-scroll" aria-expanded={if(@collapsed, do: "false", else: "true")} aria-label={if(@collapsed, do: "Expand navigation", else: "Collapse navigation")} title={if(@collapsed, do: "Expand navigation", else: "Collapse navigation")} disabled={!@page_mounted?} $click="toggle">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="design-menu-chevron" aria-hidden="true"><path d="m14 6-6 6 6 6m6-12-6 6 6 6" /></svg>
      </button>
    </nav>
    """
  end
end
