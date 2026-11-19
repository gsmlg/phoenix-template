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
           "Compare the same color roles in the light and dark themes."}

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
          <div class="grid gap-4 xl:grid-cols-2" id="token-examples">
            <section
              :for={{theme, label} <- [{"sunshine", "Light"}, {"moonlight", "Dark"}]}
              data-theme={theme}
              aria-labelledby={"token-theme-#{theme}"}
              class="rounded-xl border border-outline-variant bg-surface p-4 text-on-surface"
            >
              <div class="mb-4 flex items-baseline gap-3">
                <h3 id={"token-theme-#{theme}"} class="font-semibold">{label}</h3>
                <code class="text-xs text-on-surface-variant">{theme}</code>
              </div>
              <dl class="grid grid-cols-2 gap-3 sm:grid-cols-3">
                <div class="rounded-xl border border-outline-variant bg-primary p-4 text-primary-content">
                  <dt class="text-sm font-semibold">Primary</dt>
                  <dd class="mt-6 text-xs">The main action</dd>
                </div>
                <div class="rounded-xl border border-outline-variant bg-secondary p-4 text-secondary-content">
                  <dt class="text-sm font-semibold">Secondary</dt>
                  <dd class="mt-6 text-xs">Supporting emphasis</dd>
                </div>
                <div class="rounded-xl border border-outline-variant bg-tertiary p-4 text-tertiary-content">
                  <dt class="text-sm font-semibold">Tertiary</dt>
                  <dd class="mt-6 text-xs">A distinct accent</dd>
                </div>
                <div class="rounded-xl border border-outline-variant bg-surface p-4 text-on-surface">
                  <dt class="text-sm font-semibold">Surface</dt>
                  <dd class="mt-6 text-xs">The page canvas</dd>
                </div>
                <div class="rounded-xl border border-outline-variant bg-surface-container p-4 text-on-surface">
                  <dt class="text-sm font-semibold">Container</dt>
                  <dd class="mt-6 text-xs">A content group</dd>
                </div>
                <div class="rounded-xl border border-outline-variant bg-surface-container-high p-4 text-on-surface">
                  <dt class="text-sm font-semibold">Elevated</dt>
                  <dd class="mt-6 text-xs">A floating layer</dd>
                </div>
              </dl>
            </section>
          </div>
          <p class="mt-4 text-sm text-on-surface-variant">
            Set the app theme in <.link navigate={~p"/use-cases/settings/appearance"} class="link">Appearance settings</.link>.
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
