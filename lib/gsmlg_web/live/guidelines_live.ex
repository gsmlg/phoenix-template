defmodule GsmlgWeb.GuidelinesLive do
  use GsmlgWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Guidelines",
       specification: Gsmlg.DesignSpec.page_markdown(),
       fingerprint: String.slice(Gsmlg.DesignSpec.fingerprint(), 0, 12)
     )}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {page, title, description} =
      case socket.assigns.live_action do
        :index ->
          {"guidelines", "Guidelines",
           "A shared visual language you can read, inspect, and adopt in your application."}

        :colors ->
          {"tokens", "Semantic colors",
           "Color roles stay consistent while their appearance adapts to the selected theme."}

        :specification ->
          {"specification", "Design specification",
           "This page and the downloadable Markdown use the same canonical source."}
      end

    {:noreply, assign(socket, current_page: page, page_title: title, description: description)}
  end

  @impl true
  def handle_event("theme_changed", _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active="guidelines" page={@current_page}>
      <div class="design-page">
        <p class="design-eyebrow">02 / THE SHARED CONTRACT</p>
        <div class="flex flex-wrap items-end justify-between gap-6">
          <div>
            <h1 class="design-title">
              {if @live_action == :index, do: "Guidelines that travel.", else: @page_title}
            </h1><p class="design-lead">
              {@description}
            </p>
          </div>
          <a id="download-design" href={~p"/guidelines/DESIGN.md"} class="btn btn-primary" download>Download DESIGN.md ↓</a>
        </div>
        <div class="mt-6 flex flex-wrap gap-3 text-xs text-on-surface-variant">
          <span>Working specification</span><span aria-hidden="true">/</span><code>SHA-256 {@fingerprint}</code><span aria-hidden="true">/</span><span>English · Markdown</span>
        </div>

        <section
          :if={@live_action in [:index, :colors]}
          class="design-section"
          aria-labelledby="tokens-title"
        >
          <div class="design-section-heading">
            <h2 id="tokens-title">Color has a job to do.</h2><a
              href="https://github.com/duskmoon-dev/design"
              class="design-text-link"
            >Token source ↗</a>
          </div>
          <div class="grid gap-3 sm:grid-cols-3 lg:grid-cols-6" id="token-examples">
            <div class="rounded-xl border border-outline-variant bg-primary p-4 text-primary-content">
              <p class="text-sm font-semibold">Primary</p><p class="mt-6 text-xs">The main action</p>
            </div>
            <div class="rounded-xl border border-outline-variant bg-secondary p-4 text-secondary-content">
              <p class="text-sm font-semibold">Secondary</p><p class="mt-6 text-xs">
                Supporting emphasis
              </p>
            </div>
            <div class="rounded-xl border border-outline-variant bg-tertiary p-4 text-tertiary-content">
              <p class="text-sm font-semibold">Tertiary</p><p class="mt-6 text-xs">
                A distinct accent
              </p>
            </div>
            <div class="rounded-xl border border-outline-variant bg-surface p-4 text-on-surface">
              <p class="text-sm font-semibold">Surface</p><p class="mt-6 text-xs">The page canvas</p>
            </div>
            <div class="rounded-xl border border-outline-variant bg-surface-container p-4 text-on-surface">
              <p class="text-sm font-semibold">Container</p><p class="mt-6 text-xs">
                A content group
              </p>
            </div>
            <div class="rounded-xl border border-outline-variant bg-surface-container-high p-4 text-on-surface">
              <p class="text-sm font-semibold">Elevated</p><p class="mt-6 text-xs">
                A floating layer
              </p>
            </div>
          </div>
          <p class="mt-4 text-sm text-on-surface-variant">
            Change the color mode in <.link navigate={~p"/use-cases/settings/appearance"} class="link">Appearance settings</.link>. The semantic roles stay the same; their appearance adapts.
          </p>
        </section>
        <section
          :if={@live_action in [:index, :specification]}
          class="design-section design-guidelines"
          aria-label="Complete design specification"
        >
          <.dm_markdown_body id="design-specification" source={@specification} />
        </section>
      </div>
    </Layouts.app>
    """
  end
end
