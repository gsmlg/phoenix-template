defmodule GsmlgWeb.UILive do
  use GsmlgWeb, :live_view

  @items ["Phoenix LiveView", "DuskMoon Hologram", "Session Process"]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "UI examples",
       name: "",
       error: nil,
       saved: nil,
       query: "",
       items: @items,
       confirming: false,
       removed: false,
       progress: 0
     )}
  end

  @impl true
  def handle_event("validate", %{"profile" => %{"name" => name}}, socket) do
    {:noreply, assign(socket, name: name, error: name_error(name), saved: nil)}
  end

  def handle_event("save", %{"profile" => %{"name" => name}}, socket) do
    error = name_error(name)

    {:noreply,
     assign(socket,
       name: name,
       error: error,
       saved: if(is_nil(error), do: String.trim(name), else: nil)
     )}
  end

  def handle_event("filter", %{"search" => %{"query" => query}}, socket) do
    items = Enum.filter(@items, &String.contains?(String.downcase(&1), String.downcase(query)))
    {:noreply, assign(socket, query: query, items: items)}
  end

  def handle_event("ask_remove", _, socket), do: {:noreply, assign(socket, confirming: true)}
  def handle_event("cancel_remove", _, socket), do: {:noreply, assign(socket, confirming: false)}

  def handle_event("confirm_remove", _, %{assigns: %{confirming: true}} = socket),
    do: {:noreply, assign(socket, confirming: false, removed: true)}

  def handle_event("confirm_remove", _, socket), do: {:noreply, socket}
  def handle_event("restore", _, socket), do: {:noreply, assign(socket, removed: false)}

  def handle_event("advance", _, socket),
    do: {:noreply, update(socket, :progress, &min(&1 + 25, 100))}

  def handle_event("reset_progress", _, socket), do: {:noreply, assign(socket, progress: 0)}

  defp name_error(name) do
    if String.length(String.trim(name)) in 2..60,
      do: nil,
      else: "Use between 2 and 60 characters."
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-5xl space-y-10 px-6 py-12">
        <header>
          <h1 class="text-3xl font-bold">Phoenix DuskMoon use cases</h1>
          <p class="mt-3 text-on-surface-variant">Interactive recipes for your next application. Demo data stays in this LiveView and resets on reload; nothing is saved to the database.</p>
          <nav aria-label="Example sections" class="mt-4 flex flex-wrap gap-4">
            <a href="#buttons" class="link">Buttons</a><a href="#forms" class="link">Forms</a>
            <a href="#data" class="link">Data</a><a href="#confirmation" class="link">Confirmation</a>
            <a href="#progress" class="link">Progress</a>
          </nav>
        </header>
        <section id="buttons" aria-labelledby="buttons-title" class="space-y-4">
          <h2 id="buttons-title" class="text-2xl font-semibold">Buttons and navigation</h2>
          <p>dm_btn supports variants, navigation, disabled and loading states.</p>
          <div class="flex flex-wrap gap-3">
            <.dm_btn id="home-example" navigate={~p"/"} variant="primary">Session state example</.dm_btn>
            <.dm_btn id="hologram-example" href="/hologram-demo" variant="outline">Hologram example</.dm_btn>
            <.dm_btn id="disabled-example" disabled variant="secondary">Disabled</.dm_btn>
            <.dm_btn id="loading-example" loading disabled>Loading preview</.dm_btn>
          </div>
        </section>
        <section id="forms" aria-labelledby="forms-title" class="space-y-4">
          <h2 id="forms-title" class="text-2xl font-semibold">Validated form and feedback</h2>
          <p>dm_form + dm_input with server validation. Save uses a native submit button.</p>
          <.dm_form id="profile-form" for={%{}} as={:profile} phx-change="validate" phx-submit="save" novalidate>
            <.dm_input id="profile-name" name="profile[name]" label="Display name" value={@name}
              errors={if @error, do: [@error], else: []} helper="2–60 characters; demo only." maxlength="60" />
            <:actions><.dm_btn id="save-profile" native_submit variant="primary">Save demo</.dm_btn></:actions>
          </.dm_form>
          <div :if={@saved} id="saved-profile" role="status">
            <.dm_alert variant="success">Saved demo profile for {@saved}. No database write occurred.</.dm_alert>
          </div>
        </section>
        <section id="data" aria-labelledby="data-title" class="space-y-4">
          <h2 id="data-title" class="text-2xl font-semibold">Cards, status badges and empty results</h2>
          <.dm_form id="search-form" for={%{}} as={:search} phx-change="filter" phx-submit="filter">
            <.dm_input id="search-query" name="search[query]" type="search" label="Filter examples" value={@query} />
          </.dm_form>
          <div id="example-results" class="grid gap-4 md:grid-cols-3" aria-live="polite">
            <.dm_card :for={item <- @items} variant="bordered">
              <:title>{item}</:title>
              <.dm_badge variant="info">Example</.dm_badge>
              <p class="mt-3">Use this pattern as a starting point, then add your application's domain logic.</p>
            </.dm_card>
            <p :if={@items == []} id="empty-results" role="status">No matching examples. Clear the search to show all.</p>
          </div>
        </section>
        <section id="confirmation" aria-labelledby="confirmation-title" class="space-y-4">
          <h2 id="confirmation-title" class="text-2xl font-semibold">Application-owned confirmation</h2>
          <p>Confirmation state belongs to the LiveView. Cancel does nothing; this demo never deletes real data.</p>
          <.dm_btn :if={!@removed && !@confirming} id="ask-remove" phx-click="ask_remove" variant="error">Remove demo item</.dm_btn>
          <section :if={@confirming} id="confirm-panel" aria-labelledby="confirm-title" class="rounded-lg border border-outline p-4">
            <h3 id="confirm-title">Remove this demo item?</h3>
            <div class="mt-3 flex gap-3">
              <.dm_btn id="cancel-remove" phx-click="cancel_remove" variant="outline">Cancel</.dm_btn>
              <.dm_btn id="confirm-remove" phx-click="confirm_remove" variant="error">Confirm removal</.dm_btn>
            </div>
          </section>
          <p :if={@removed} id="removed-item" role="status">Demo item removed.</p>
          <.dm_btn :if={@removed} id="restore-item" phx-click="restore" variant="outline">Restore demo item</.dm_btn>
        </section>
        <section id="progress" aria-labelledby="progress-title" class="space-y-4">
          <h2 id="progress-title" class="text-2xl font-semibold">Progress and completion</h2>
          <p>Each click simulates a completed step. This is not a real background job.</p>
          <.dm_progress id="demo-progress" value={@progress} label_text="Demo completion" aria-label="Demo completion" show_label />
          <div class="flex gap-3">
            <.dm_btn id="advance-progress" phx-click="advance" disabled={@progress == 100}>Complete one step</.dm_btn>
            <.dm_btn id="reset-progress" phx-click="reset_progress" variant="outline">Reset</.dm_btn>
          </div>
          <.dm_badge :if={@progress == 100} variant="success">Complete</.dm_badge>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
