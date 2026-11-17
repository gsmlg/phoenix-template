defmodule GsmlgWeb.ComponentsLive do
  use GsmlgWeb, :live_view

  @snippets %{
    core: ~S"""
    <button class="btn btn-primary">Add item</button>
    <span class="badge badge-success">Ready</span>
    <div class="card bg-surface-container text-on-surface">
      <div class="card-body">A shared visual foundation.</div>
    </div>
    """,
    elements: ~S"""
    import { registerAll } from "@duskmoon-dev/elements";
    registerAll();

    <el-dm-card padding="lg">
      <h3 slot="header">Workspace preferences</h3>
      <el-dm-input label="Workspace name" value="Shared workspace"></el-dm-input>
      <el-dm-switch label="Email summaries"></el-dm-switch>
    </el-dm-card>
    """,
    phoenix: ~S"""
    <.dm_card variant="bordered">
      <:title>Release checklist</:title>
      <.dm_badge variant="info">In review</.dm_badge>
      <.dm_progress value={50} max={100} show_label label_text="Review progress" />
      <:action>
        <.dm_btn variant="primary" phx-click="advance">Complete next step</.dm_btn>
      </:action>
    </.dm_card>
    """,
    react: ~S"""
    import { Button, Card, Badge } from "@duskmoon-dev/components";
    import "@duskmoon-dev/components/styles.css";

    <Card appearance="outline" padding="lg">
      <Badge color="info" appearance="tonal">In review</Badge>
      <Button color="primary" onClick={approve}>Approve item</Button>
    </Card>
    """
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Components",
       core_count: 0,
       preview_label: "Release checklist",
       progress: 0,
       snippets: @snippets
     )}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {page, title, description} =
      case socket.assigns.live_action do
        :index ->
          {"components", "Components",
           "One visual language, four integration paths. Try the components here or open a dedicated integration page."}

        :core ->
          {"core", "Core CSS",
           "Style native HTML with shared semantic tokens and browser-native behavior."}

        :elements ->
          {"elements", "Web Components",
           "Use registered DuskMoon custom elements with their browser-owned state."}

        :phoenix ->
          {"phoenix", "Phoenix components",
           "Compose HEEx components with server-connected LiveView interactions."}

        :react ->
          {"react", "React components",
           "Explore the React adapter in an isolated document with the shared theme."}
      end

    {:noreply, assign(socket, current_page: page, page_title: title, description: description)}
  end

  @impl true
  def handle_event("core-add", _params, socket) do
    {:noreply, update(socket, :core_count, &(&1 + 1))}
  end

  def handle_event("core-reset", _params, socket) do
    {:noreply, assign(socket, core_count: 0)}
  end

  def handle_event("preview-label", %{"preview" => %{"label" => label}}, socket) do
    {:noreply, assign(socket, preview_label: String.slice(label, 0, 60))}
  end

  def handle_event("preview-label", _params, socket), do: {:noreply, socket}

  def handle_event("preview-advance", _params, socket) do
    {:noreply, update(socket, :progress, &min(&1 + 25, 100))}
  end

  def handle_event("preview-reset", _params, socket) do
    {:noreply, assign(socket, progress: 0, preview_label: "Release checklist")}
  end

  def handle_event("theme_changed", _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active="components" page={@current_page}>
      <div class="design-page">
        <header class="max-w-3xl">
          <p class="design-eyebrow">The building blocks</p>
          <h1 class="design-title">{@page_title}</h1>
          <p class="design-lead">
            {@description}
          </p>
        </header>

        <nav
          :if={@live_action == :index}
          aria-label="Component sections"
          class="flex flex-wrap gap-2 border-b border-outline-variant pb-5"
        >
          <.link navigate={~p"/components/core"} class="btn btn-ghost">Core CSS</.link>
          <.link navigate={~p"/components/elements"} class="btn btn-ghost">Web Components</.link>
          <.link navigate={~p"/components/phoenix"} class="btn btn-ghost">Phoenix</.link>
          <.link navigate={~p"/components/react"} class="btn btn-ghost">React</.link>
        </nav>

        <section
          :if={@live_action in [:index, :core]}
          id="core"
          aria-labelledby="core-title"
          class="design-section scroll-mt-24"
        >
          <div class="flex flex-wrap items-start justify-between gap-4">
            <div class="max-w-2xl">
              <p class="design-eyebrow">01 / Style native HTML</p>
              <h2 id="core-title" class="design-section-heading">Core CSS</h2>
              <p class="mt-3 text-on-surface-variant">
                Use Core when you need semantic styles on native HTML. It supplies the
                tokens, themes, and component classes shared by every adapter. In this
                example, LiveView supplies the counter behavior.
              </p>
            </div>
            <a href="https://github.com/duskmoon-dev/duskmoonui" class="link text-sm text-primary">
              Core source <span aria-hidden="true">↗</span>
            </a>
          </div>
          <div class="design-preview">
            <div class="design-preview-body">
              <div class="card w-full max-w-xl border border-outline-variant bg-surface-container text-on-surface">
                <div class="card-body gap-5">
                  <div class="flex items-start justify-between gap-4">
                    <div>
                      <h3 class="text-lg font-semibold">A small collection</h3>
                      <p class="mt-1 text-sm text-on-surface-variant">
                        Native buttons, shared styles.
                      </p>
                    </div>
                    <span class="badge badge-success">Ready</span>
                  </div>
                  <p id="core-count" class="text-3xl font-semibold tabular-nums" aria-live="polite">
                    {@core_count} items
                  </p>
                  <div class="flex flex-wrap gap-3">
                    <button id="core-add" type="button" class="btn btn-primary" phx-click="core-add">
                      Add item
                    </button>
                    <button
                      id="core-reset"
                      type="button"
                      class="btn btn-outline"
                      phx-click="core-reset"
                    >
                      Reset collection
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <details class="border-t border-outline-variant">
              <summary class="cursor-pointer px-6 py-4 text-sm font-medium">View Core markup</summary>
              <pre class="design-code"><code>{@snippets.core}</code></pre>
            </details>
          </div>
        </section>

        <section
          :if={@live_action in [:index, :elements]}
          id="elements"
          aria-labelledby="elements-title"
          class="design-section scroll-mt-24"
        >
          <div class="flex flex-wrap items-start justify-between gap-4">
            <div class="max-w-2xl">
              <p class="design-eyebrow">02 / Bring your own framework</p>
              <h2 id="elements-title" class="design-section-heading">Web Components</h2>
              <p class="mt-3 text-on-surface-variant">
                Use custom elements for browser-owned controls with encapsulated styling.
                The controls below use the installed aggregate package. Their local state
                belongs to this preview and resets when the document reloads.
              </p>
            </div>
            <a
              href="https://github.com/duskmoon-dev/duskmoon-elements"
              class="link text-sm text-primary"
            >
              Elements source <span aria-hidden="true">↗</span>
            </a>
          </div>
          <%!-- TODO(upstream): duskmoon-dev/duskmoon-elements#90 --%>
          <p id="elements-known-issue" class="mb-5 text-sm text-on-surface-variant" role="note">
            Preview limitation: the current input loses focus before typing. Interactive
            input acceptance is pending <a
              class="link"
              href="https://github.com/duskmoon-dev/duskmoon-elements/issues/90"
            >upstream issue #90</a>.
          </p>
          <div class="design-preview">
            <div id="elements-preview" phx-update="ignore" class="design-preview-body">
              <el-dm-card padding="lg" class="block w-full max-w-xl">
                <h3 slot="header" class="text-lg font-semibold">Workspace preferences</h3>
                <div class="space-y-5">
                  <el-dm-input
                    id="elements-name"
                    label="Workspace name"
                    value="Shared workspace"
                    maxlength="60"
                  >
                  </el-dm-input>
                  <el-dm-switch id="elements-switch" label="Email summaries" color="primary">
                  </el-dm-switch>
                  <p class="text-sm text-on-surface-variant">
                    These controls run in the browser. No preferences are saved.
                  </p>
                </div>
                <span slot="footer" class="text-sm text-on-surface-variant">
                  Registered through the aggregate elements package.
                </span>
              </el-dm-card>
            </div>
            <details class="border-t border-outline-variant">
              <summary class="cursor-pointer px-6 py-4 text-sm font-medium">
                View Elements setup
              </summary>
              <pre class="design-code"><code>{@snippets.elements}</code></pre>
            </details>
          </div>
        </section>

        <section
          :if={@live_action in [:index, :phoenix]}
          id="phoenix"
          aria-labelledby="phoenix-title"
          class="design-section scroll-mt-24"
        >
          <div class="flex flex-wrap items-start justify-between gap-4">
            <div class="max-w-2xl">
              <p class="design-eyebrow">03 / Server-connected interaction</p>
              <h2 id="phoenix-title" class="design-section-heading">Phoenix components</h2>
              <p class="mt-3 text-on-surface-variant">
                Use HEEx components when state and validation belong to LiveView. Change
                the checklist name and advance the review. Component attributes and slots
                keep the markup consistent while your application owns the behavior.
              </p>
            </div>
            <a
              href="https://github.com/duskmoon-dev/phoenix-duskmoon-ui"
              class="link text-sm text-primary"
            >
              Phoenix source <span aria-hidden="true">↗</span>
            </a>
          </div>
          <div class="design-preview">
            <div class="design-preview-body">
              <div class="w-full max-w-xl space-y-5">
                <.dm_form
                  id="component-label-form"
                  for={%{}}
                  as={:preview}
                  phx-change="preview-label"
                  phx-submit="preview-label"
                >
                  <.dm_input
                    id="component-label"
                    name="preview[label]"
                    label="Checklist name"
                    value={@preview_label}
                    maxlength="60"
                    helper="Updates the preview only. No database write."
                  />
                </.dm_form>
                <.dm_card id="phoenix-card-preview" variant="bordered">
                  <:title><span id="component-label-output">{@preview_label}</span></:title>
                  <div class="space-y-5">
                    <.dm_badge variant={if @progress == 100, do: "success", else: "info"} soft>
                      {if @progress == 100, do: "Review complete", else: "In review"}
                    </.dm_badge>
                    <.dm_progress
                      id="component-progress"
                      value={@progress}
                      max={100}
                      show_label
                      label_text="Review progress"
                      aria-label="Review progress"
                    />
                    <div :if={@progress == 100} id="component-complete" role="status">
                      <.dm_alert variant="success">
                        All four example review steps are complete.
                      </.dm_alert>
                    </div>
                  </div>
                  <:action>
                    <.dm_btn
                      id="component-advance"
                      variant="primary"
                      phx-click="preview-advance"
                      disabled={@progress == 100}
                    >
                      Complete next step
                    </.dm_btn>
                    <.dm_btn id="component-reset" variant="outline" phx-click="preview-reset">
                      Reset review
                    </.dm_btn>
                  </:action>
                </.dm_card>
              </div>
            </div>
            <details class="border-t border-outline-variant">
              <summary class="cursor-pointer px-6 py-4 text-sm font-medium">
                View HEEx composition
              </summary>
              <pre class="design-code"><code>{@snippets.phoenix}</code></pre>
            </details>
          </div>
        </section>

        <section
          :if={@live_action in [:index, :react]}
          id="react"
          aria-labelledby="react-title"
          class="design-section scroll-mt-24"
        >
          <div class="flex flex-wrap items-start justify-between gap-4">
            <div class="max-w-2xl">
              <p class="design-eyebrow">04 / Client-side application state</p>
              <h2 id="react-title" class="design-section-heading">React components</h2>
              <p class="mt-3 text-on-surface-variant">
                Use the React adapter for React applications. This is a running React
                preview with its own state and document, sharing the same theme and Core
                styles. It does not mount into LiveView's DOM.
              </p>
            </div>
            <a href="https://github.com/duskmoon-dev/duskmoon-react" class="link text-sm text-primary">
              React source <span aria-hidden="true">↗</span>
            </a>
          </div>
          <div class="design-preview">
            <iframe
              id="react-component-preview"
              src={~p"/previews/react"}
              title="Interactive DuskMoon React approval example"
              class="block min-h-96 w-full border-0 bg-surface-container-low"
              loading="lazy"
            ></iframe>
            <details class="border-t border-outline-variant">
              <summary class="cursor-pointer px-6 py-4 text-sm font-medium">
                View React composition
              </summary>
              <pre class="design-code"><code>{@snippets.react}</code></pre>
            </details>
          </div>
          <p class="text-sm text-on-surface-variant">
            The preview uses Components 0.5.5 with React 19, a compatible cohort for this
            template's Core version. These are runnable examples, not an exhaustive catalog.
          </p>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
