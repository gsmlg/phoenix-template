defmodule GsmlgWeb.Layouts do
  use GsmlgWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="sticky top-0 z-50">
      <nav class="navbar navbar-surface-container-high border-b border-outline-variant">
        <div class="mx-auto flex w-full max-w-7xl items-center justify-between px-4 sm:px-6">
          <a href={~p"/"} class="flex items-center gap-3 text-xl font-semibold text-primary">
            <span class="grid size-9 place-items-center rounded-lg bg-primary text-primary-content">P</span>
            Phoenix Template
          </a>
          <div class="flex items-center gap-2 text-sm">
            <a href="https://hexdocs.pm/phoenix" class="btn btn-ghost">Docs</a>
            <.dm_theme_switcher />
          </div>
        </div>
      </nav>
    </header>

    <main class="min-h-[calc(100dvh-9rem)] bg-surface">
      {render_slot(@inner_block)}
    </main>

    <footer class="border-t border-outline-variant bg-surface-container-low">
      <div class="mx-auto flex max-w-7xl flex-col gap-2 px-4 py-6 text-sm text-on-surface-variant sm:flex-row sm:items-center sm:justify-between sm:px-6">
        <span>Built with Phoenix 1.8 and DuskMoon</span>
        <a href="https://github.com/gsmlg/phoenix-template" class="hover:text-primary">Source</a>
      </div>
    </footer>

    <.dm_flash_group flash={@flash} />
    """
  end
end
