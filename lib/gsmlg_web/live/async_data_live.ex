defmodule GsmlgWeb.AsyncDataLive do
  use GsmlgWeb, :live_view

  @workspace %{name: "Atlas workspace", owner: "Design systems"}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "Async data loading") |> load_workspace(false)}
  end

  @impl true
  def handle_event(event, _params, socket) when event in ["load_workspace", "simulate_failure"] do
    if socket.assigns.workspace.loading do
      {:noreply, socket}
    else
      {:noreply, load_workspace(socket, event == "simulate_failure")}
    end
  end

  defp load_workspace(socket, fail?) do
    assign_async(
      socket,
      :workspace,
      fn ->
        Process.sleep(1_200)

        if fail?, do: {:error, :unavailable}, else: {:ok, %{workspace: @workspace}}
      end,
      reset: true
    )
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active="use-cases" page="async-data">
      <div class="design-page">
        <header class="max-w-3xl">
          <p class="design-eyebrow">Reference / Use cases</p>
          <h1 class="design-title">{@page_title}</h1>
          <p class="design-lead">
            Use <code>assign_async/3</code>
            for database and external API reads that can finish after the page opens. Navigation stays available while the data loads.
          </p>
        </header>

        <section class="design-section max-w-3xl" aria-labelledby="async-workspace-title">
          <div class="design-preview">
            <div class="design-preview-body">
              <h2 id="async-workspace-title" class="text-xl font-semibold">Workspace details</h2>
              <p class="mt-2 text-sm text-on-surface-variant">
                This example simulates a slow response.
              </p>

              <div class="mt-4 flex min-h-24 items-center">
                <.async_result :let={workspace} assign={@workspace}>
                  <:loading>
                    <.dm_loading_spinner
                      id="async-workspace-loading"
                      size="sm"
                      text="Loading workspace…"
                    />
                  </:loading>
                  <:failed>
                    <.dm_alert id="async-workspace-error" variant="error">
                      Could not load the workspace. Try again.
                    </.dm_alert>
                  </:failed>
                  <div id="async-workspace-result">
                    <h3 class="font-semibold">{workspace.name}</h3>
                    <p class="mt-1 text-sm text-on-surface-variant">Owned by {workspace.owner}</p>
                  </div>
                </.async_result>
              </div>

              <div class="mt-4 flex flex-wrap gap-3">
                <.dm_btn
                  id="async-workspace-reload"
                  variant="primary"
                  phx-click="load_workspace"
                  disabled={!!@workspace.loading}
                >
                  {if @workspace.failed, do: "Retry", else: "Reload"}
                </.dm_btn>
                <.dm_btn
                  id="async-workspace-simulate-failure"
                  variant="outline"
                  phx-click="simulate_failure"
                  disabled={!!@workspace.loading}
                >
                  Simulate failure
                </.dm_btn>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
