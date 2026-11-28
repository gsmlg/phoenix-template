defmodule GsmlgWeb.UseCasesLive do
  use GsmlgWeb, :live_view

  @initial_name "Design workspace"
  @records [
    %{
      id: "atlas",
      name: "Atlas workspace",
      owner: "Design systems",
      status: "active",
      description: "A shared workspace for reviewing interface foundations and components."
    },
    %{
      id: "guide",
      name: "Guide workspace",
      owner: "Documentation",
      status: "active",
      description: "A reference workspace for publishing guidance and implementation notes."
    },
    %{
      id: "relay",
      name: "Relay workspace",
      owner: "Product team",
      status: "draft",
      description: "A draft workspace for trying a new product workflow before publication."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Use Cases",
       name: @initial_name,
       saved_name: @initial_name,
       error: nil,
       saved: nil,
       query: "",
       status: "all",
       items: @records,
       selected: nil,
       confirming: false,
       removed: false,
       progress: 0
     )}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {page, title, description} =
      case socket.assigns.live_action do
        :index ->
          {"use-cases", "Use Cases",
           "Practical workflows drawn from real applications. Try the edge cases, then carry the pattern into your own product."}

        :workspace_settings ->
          {"settings", "Workspace settings",
           "Validate a workspace name, save a draft, and recover through cancellation."}

        :records ->
          {"records", "Record browser",
           "Combine search and status filters, inspect records, and recover from empty results."}

        :confirmation ->
          {"confirmation", "Confirmation",
           "Name the affected object and confirm the consequences before removing it."}

        :progress ->
          {"progress", "Progress",
           "Present bounded job progress with accurate status and a reset path."}
      end

    {:noreply, assign(socket, current_page: page, page_title: title, description: description)}
  end

  @impl true
  def handle_event("validate", %{"profile" => %{"name" => name}}, socket) do
    {:noreply, assign(socket, name: name, error: name_error(name), saved: nil)}
  end

  def handle_event("save", %{"profile" => %{"name" => name}}, socket) do
    error = name_error(name)
    saved = if is_nil(error), do: String.trim(name)

    {:noreply,
     assign(socket,
       name: if(saved, do: saved, else: name),
       error: error,
       saved: saved,
       saved_name: saved || socket.assigns.saved_name
     )}
  end

  def handle_event("cancel_settings", _, socket) do
    {:noreply, assign(socket, name: socket.assigns.saved_name, error: nil, saved: nil)}
  end

  def handle_event("filter", %{"search" => search}, socket) do
    query = Map.get(search, "query", socket.assigns.query)
    status = Map.get(search, "status", socket.assigns.status)
    status = if status in ~w(all active draft), do: status, else: "all"
    items = filter_records(query, status)
    selected = Enum.find(items, &(&1 == socket.assigns.selected))

    {:noreply, assign(socket, query: query, status: status, items: items, selected: selected)}
  end

  def handle_event("clear_filters", _, socket) do
    {:noreply, assign(socket, query: "", status: "all", items: @records, selected: nil)}
  end

  def handle_event("select_record", %{"id" => id}, socket) do
    case Enum.find(socket.assigns.items, &(&1.id == id)) do
      nil -> {:noreply, socket}
      record -> {:noreply, assign(socket, selected: record)}
    end
  end

  def handle_event("ask_remove", _, %{assigns: %{removed: false}} = socket),
    do: {:noreply, assign(socket, confirming: true)}

  def handle_event("ask_remove", _, socket), do: {:noreply, socket}

  def handle_event("cancel_remove", _, socket),
    do: {:noreply, assign(socket, confirming: false)}

  def handle_event("confirm_remove", _, %{assigns: %{confirming: true}} = socket),
    do: {:noreply, assign(socket, confirming: false, removed: true)}

  def handle_event("confirm_remove", _, socket), do: {:noreply, socket}

  def handle_event("restore", _, socket),
    do: {:noreply, assign(socket, confirming: false, removed: false)}

  def handle_event("advance", _, socket),
    do: {:noreply, update(socket, :progress, &min(&1 + 25, 100))}

  def handle_event("reset_progress", _, socket),
    do: {:noreply, assign(socket, progress: 0)}

  def handle_event("theme_changed", _params, socket), do: {:noreply, socket}

  defp name_error(name) do
    if String.length(String.trim(name)) in 2..60,
      do: nil,
      else: "Use between 2 and 60 characters."
  end

  defp filter_records(query, status) do
    query = query |> String.trim() |> String.downcase()

    Enum.filter(@records, fn record ->
      matches_query =
        String.contains?(String.downcase(record.name <> " " <> record.owner), query)

      matches_query and (status == "all" or record.status == status)
    end)
  end

  defp progress_label(0), do: "Ready to start"
  defp progress_label(100), do: "Complete"
  defp progress_label(_), do: "In progress"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active="use-cases" page={@current_page}>
      <div class="design-page">
        <header>
          <p class="design-eyebrow">Reference / Use cases</p>
          <h1 class="design-title">
            {if @live_action == :index, do: "Components, working together.", else: @page_title}
          </h1>
          <p class="design-lead">
            {@description}
          </p>
          <p class="mt-4 text-sm text-on-surface-variant">
            All records are synthetic. Changes stay in this page and reset on reload.
          </p>
          <nav
            :if={@live_action == :index}
            aria-label="Use case sections"
            class="mt-6 flex flex-wrap gap-x-5 gap-y-2 text-sm"
          >
            <.link navigate={~p"/use-cases/workspace-settings"} class="link">Workspace settings</.link>
            <.link navigate={~p"/use-cases/records"} class="link">Record browser</.link>
            <.link navigate={~p"/use-cases/confirmation"} class="link">Confirmation</.link>
            <.link navigate={~p"/use-cases/progress"} class="link">Job progress</.link>
            <.link navigate={~p"/use-cases/async-data"} class="link">Async data loading</.link>
            <.link navigate={~p"/use-cases/react-chat"} class="link">React Chat</.link>
            <.link navigate={~p"/use-cases/react-form"} class="link">React Form</.link>
          </nav>
        </header>

        <section
          :if={@live_action in [:index, :workspace_settings]}
          id="workspace-settings"
          aria-labelledby="settings-title"
          class="design-section"
        >
          <div class="design-section-heading">
            <div>
              <p class="design-eyebrow">01 / Edit and save</p>
              <h2 id="settings-title" class="text-2xl font-semibold">Workspace settings</h2>
            </div>
            <.dm_badge variant="neutral" outline>Form + feedback</.dm_badge>
          </div>
          <p class="max-w-3xl text-on-surface-variant">
            Validate close to the field, keep a recoverable draft, and make the save boundary clear.
            Cancel restores the last value saved in this preview.
          </p>
          <p class="mt-3 text-sm">
            <.link navigate={~p"/use-cases/settings"} class="design-text-link">
              Open the settings page layout →
            </.link>
          </p>
          <div class="design-preview mt-6">
            <div class="design-preview-body grid gap-8 lg:grid-cols-[minmax(0,1fr)_minmax(0,0.8fr)]">
              <div>
                <.dm_form
                  id="profile-form"
                  for={%{}}
                  as={:profile}
                  phx-change="validate"
                  phx-submit="save"
                  actions_align="right"
                  novalidate
                >
                  <.dm_input
                    id="profile-name"
                    name="profile[name]"
                    label="Workspace name"
                    value={@name}
                    errors={if @error, do: [@error], else: []}
                    helper="Use 2-60 characters. This preview does not write to a database."
                    maxlength="60"
                  />
                  <:actions>
                    <.dm_btn
                      id="cancel-settings"
                      phx-click="cancel_settings"
                      variant="ghost"
                      type="button"
                    >
                      Cancel changes
                    </.dm_btn>
                    <.dm_btn id="save-profile" native_submit variant="primary">
                      Save workspace
                    </.dm_btn>
                  </:actions>
                </.dm_form>
                <div :if={@saved} id="saved-profile" class="mt-4" role="status">
                  <.dm_alert variant="success">
                    Saved {@saved} for this preview. Reloading restores the original value.
                  </.dm_alert>
                </div>
              </div>
              <aside class="border-l border-outline-variant pl-6 text-sm">
                <h3 class="font-semibold">Try the recovery path</h3>
                <ol class="mt-3 list-inside list-decimal space-y-2 text-on-surface-variant">
                  <li>Enter one character and save.</li>
                  <li>Correct the name and submit with Enter.</li>
                  <li>Edit again, then cancel your changes.</li>
                </ol>
                <p class="mt-4 font-mono text-xs text-on-surface-variant">
                  dm_form · dm_input · dm_btn · dm_alert
                </p>
              </aside>
            </div>
            <div class="border-t border-outline-variant px-6 py-4 text-sm text-on-surface-variant">
              Adapted from <a
                class="link"
                href="https://github.com/gsmlg-opt/sigma/blob/f19cfae16d9e4c0040ab041c15a394edf95a9534/apps/sigma_web/lib/sigma_web/live/hooks_settings_component.ex#L131"
              >Sigma's editable settings</a>.
              The original pattern combines field inputs, save, and cancellation.
            </div>
          </div>
        </section>

        <section
          :if={@live_action in [:index, :records]}
          id="record-browser"
          aria-labelledby="records-title"
          class="design-section"
        >
          <div class="design-section-heading">
            <div>
              <p class="design-eyebrow">02 / Find and inspect</p>
              <h2 id="records-title" class="text-2xl font-semibold">A useful empty state</h2>
            </div>
            <.dm_badge variant="neutral" outline>Search + detail</.dm_badge>
          </div>
          <p class="max-w-3xl text-on-surface-variant">
            Combine search and a status filter without losing the next step. Select a record
            to inspect it; filtering that record out also clears its detail panel.
          </p>
          <div class="design-preview mt-6">
            <div class="design-preview-body">
              <.dm_form
                id="search-form"
                for={%{}}
                as={:search}
                phx-change="filter"
                phx-submit="filter"
                class="grid items-end gap-4 md:grid-cols-[minmax(0,1fr)_12rem]"
              >
                <.dm_input
                  id="search-query"
                  name="search[query]"
                  type="search"
                  label="Find a workspace"
                  value={@query}
                  placeholder="Search by name or team"
                />
                <.dm_input
                  id="search-status"
                  name="search[status]"
                  type="select"
                  label="Status"
                  value={@status}
                  options={[{"All statuses", "all"}, {"Active", "active"}, {"Draft", "draft"}]}
                />
              </.dm_form>
              <p id="result-count" class="my-4 text-sm text-on-surface-variant" role="status">
                {length(@items)} {if length(@items) == 1, do: "workspace", else: "workspaces"}
              </p>
              <div id="example-results" class="overflow-x-auto">
                <.dm_table :if={@items != []} id="workspace-records" data={@items}>
                  <:caption class="sr-only">Synthetic workspace records</:caption>
                  <:col :let={item} label="Workspace">
                    <span class="font-medium">{item.name}</span>
                  </:col>
                  <:col :let={item} label="Team">{item.owner}</:col>
                  <:col :let={item} label="Status">
                    <.dm_badge
                      variant={if item.status == "active", do: "success", else: "neutral"}
                      outline
                    >
                      {String.capitalize(item.status)}
                    </.dm_badge>
                  </:col>
                  <:col :let={item} label="Action">
                    <.dm_btn
                      id={"select-record-#{item.id}"}
                      variant="ghost"
                      size="sm"
                      phx-click="select_record"
                      phx-value-id={item.id}
                      aria-label={"Inspect #{item.name}"}
                      aria-pressed={
                        if @selected != nil and @selected.id == item.id, do: "true", else: "false"
                      }
                    >
                      Inspect
                    </.dm_btn>
                  </:col>
                </.dm_table>
                <div
                  :if={@items == []}
                  id="empty-results"
                  class="rounded-xl border border-dashed border-outline-variant px-6 py-10 text-center"
                >
                  <h3 class="font-semibold">No matching workspaces</h3>
                  <p class="mt-2 text-sm text-on-surface-variant">
                    Try a different name or clear both filters to start again.
                  </p>
                  <.dm_btn id="clear-filters" class="mt-4" variant="outline" phx-click="clear_filters">
                    Clear filters
                  </.dm_btn>
                </div>
              </div>
              <section
                :if={@selected}
                id="selected-record"
                aria-labelledby="selected-record-title"
                class="mt-5 rounded-xl border border-outline-variant bg-surface-container p-5 text-on-surface"
              >
                <div class="flex flex-wrap items-center justify-between gap-3">
                  <h3 id="selected-record-title" class="font-semibold">{@selected.name}</h3>
                  <span class="text-sm text-on-surface-variant">{@selected.owner}</span>
                </div>
                <p class="mt-2 text-sm text-on-surface-variant">{@selected.description}</p>
              </section>
            </div>
            <div class="border-t border-outline-variant px-6 py-4 text-sm text-on-surface-variant">
              Inspired by <a
                class="link"
                href="https://github.com/gsmlg-opt/backplane/blob/3be870e3bbcd08a332aeda90f9438b1363b95b8a/apps/backplane_admin/lib/backplane/admin/live/memory_records_live.ex#L106"
              >Backplane's record browser</a>.
              Applied components: dm_input, dm_table, dm_badge, and dm_btn.
            </div>
          </div>
        </section>

        <section
          :if={@live_action in [:index, :confirmation]}
          id="confirmation"
          aria-labelledby="confirmation-title"
          class="design-section"
        >
          <div class="design-section-heading">
            <div>
              <p class="design-eyebrow">03 / Make consequences clear</p>
              <h2 id="confirmation-title" class="text-2xl font-semibold">Deliberate confirmation</h2>
            </div>
            <.dm_badge variant="neutral" outline>Confirm + recover</.dm_badge>
          </div>
          <p class="max-w-3xl text-on-surface-variant">
            Keep the affected object and the cancellation path visible. Confirmation is an
            application state transition, not an authorization boundary.
          </p>
          <div class="design-preview mt-6">
            <div class="design-preview-body">
              <div :if={!@removed} class="flex flex-wrap items-center justify-between gap-4">
                <div>
                  <h3 class="font-semibold">Weekly review</h3>
                  <p class="mt-1 text-sm text-on-surface-variant">
                    A synthetic saved view for this example.
                  </p>
                </div>
                <button
                  id="ask-remove"
                  type="button"
                  phx-click="ask_remove"
                  aria-haspopup="dialog"
                  class="btn btn-outline"
                >
                  Remove saved view
                </button>
              </div>
              <.dm_modal
                :if={@confirming}
                id="confirm-panel"
                size="sm"
                hide_close
                aria-describedby="confirm-description"
                phx-hook="ConfirmationDialog"
                data-return-focus="#ask-remove, #restore-item"
              >
                <:title>Remove Weekly review?</:title>
                <:body>
                  <p id="confirm-description">
                    This removes the saved view from this preview. You can restore it afterward.
                  </p>
                </:body>
                <:footer>
                  <button
                    id="cancel-remove"
                    type="button"
                    phx-click="cancel_remove"
                    class="btn btn-ghost"
                    autofocus
                  >
                    Cancel
                  </button>
                  <button
                    id="confirm-remove"
                    type="button"
                    phx-click="confirm_remove"
                    class="btn btn-error"
                  >
                    Remove saved view
                  </button>
                </:footer>
              </.dm_modal>
              <div :if={@removed} id="removed-item" role="status">
                <.dm_alert variant="success">Weekly review was removed from this preview.</.dm_alert>
                <button
                  id="restore-item"
                  type="button"
                  class="btn btn-outline mt-4"
                  phx-click="restore"
                >
                  Restore saved view
                </button>
              </div>
            </div>
            <div class="border-t border-outline-variant px-6 py-4 text-sm text-on-surface-variant">
              Inspired by <a
                class="link"
                href="https://github.com/gsmlg-opt/backplane/blob/3be870e3bbcd08a332aeda90f9438b1363b95b8a/apps/backplane_admin/lib/backplane/admin/live/host_services_live.ex#L160"
              >Backplane's edit and remove flow</a>.
              Try cancellation, confirmation, restore, and confirmation again.
            </div>
          </div>
        </section>

        <section
          :if={@live_action in [:index, :progress]}
          id="progress"
          aria-labelledby="progress-title"
          class="design-section"
        >
          <div class="design-section-heading">
            <div>
              <p class="design-eyebrow">04 / Show work in context</p>
              <h2 id="progress-title" class="text-2xl font-semibold">Progress with a real state</h2>
            </div>
            <.dm_badge variant="neutral" outline>Status + progress</.dm_badge>
          </div>
          <p class="max-w-3xl text-on-surface-variant">
            Pair a progress value with a clear state and a useful action. This simulated
            four-step publication never starts a background job.
          </p>
          <div class="design-preview mt-6">
            <div class="design-preview-body">
              <div class="mb-5 flex flex-wrap items-center justify-between gap-3">
                <div>
                  <h3 class="font-semibold">Publish design reference</h3>
                  <p class="mt-1 text-sm text-on-surface-variant">
                    Foundations → components → use cases → review
                  </p>
                </div>
                <.dm_badge
                  id="job-status"
                  variant={if @progress == 100, do: "success", else: "neutral"}
                  outline
                >
                  {progress_label(@progress)}
                </.dm_badge>
              </div>
              <.dm_progress
                id="demo-progress"
                value={@progress}
                max={100}
                label_text="Publication progress"
                aria-label="Publication progress"
                show_label
              />
              <div class="mt-5 flex flex-wrap gap-3">
                <.dm_btn
                  id="advance-progress"
                  phx-click="advance"
                  variant="primary"
                  disabled={@progress == 100}
                >
                  Complete next step
                </.dm_btn>
                <.dm_btn id="reset-progress" phx-click="reset_progress" variant="ghost">
                  Reset preview
                </.dm_btn>
              </div>
              <p class="mt-4 text-sm text-on-surface-variant">
                Each completed step adds 25%. Completion is capped at 100%; reset returns to ready.
              </p>
            </div>
            <div class="border-t border-outline-variant px-6 py-4 text-sm text-on-surface-variant">
              Status presentation informed by <a
                class="link"
                href="https://github.com/gsmlg-opt/backplane/blob/3be870e3bbcd08a332aeda90f9438b1363b95b8a/apps/backplane_admin/lib/backplane/admin/live/logs_jobs_live.ex#L53"
              >Backplane's jobs view</a>.
              The four-step percentage model is specific to this demo, not the source application.
            </div>
          </div>
        </section>

        <section :if={@live_action == :index} aria-labelledby="lifetime-title" class="design-section">
          <div class="design-section-heading">
            <div>
              <p class="design-eyebrow">Continue exploring</p>
              <h2 id="lifetime-title" class="text-2xl font-semibold">
                Choose the right state lifetime.
              </h2>
            </div>
          </div>
          <div class="grid gap-4 md:grid-cols-2">
            <.dm_card variant="bordered">
              <:title>Across tabs and refreshes</:title>
              <p class="text-sm text-on-surface-variant">
                A session counter shares temporary state across LiveView pages in one browser session.
              </p>
              <:action>
                <.dm_btn id="session-example-link" navigate={~p"/use-cases/session"} variant="outline">
                  Explore session state
                </.dm_btn>
              </:action>
            </.dm_card>
            <.dm_card variant="bordered">
              <:title>In this browser document</:title>
              <p class="text-sm text-on-surface-variant">
                Hologram actions run locally and work offline after initialization. Reload starts fresh.
              </p>
              <:action>
                <.dm_btn id="hologram-example-link" href="/hologram-demo" variant="outline">
                  Explore browser-local state
                </.dm_btn>
              </:action>
            </.dm_card>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
