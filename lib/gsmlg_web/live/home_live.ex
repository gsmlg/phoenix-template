defmodule GsmlgWeb.HomeLive do
  use GsmlgWeb, :live_view
  alias Gsmlg.PageState
  alias Phoenix.SessionProcess

  @impl true
  def mount(_params, %{"session_id" => session_id}, socket) do
    socket =
      assign(socket,
        page_title: "Starter",
        count: 0,
        session_id: session_id,
        session_pid: nil,
        session_monitor: nil,
        session_status: :ready
      )

    {:ok, load_session(socket)}
  end

  @impl true
  def handle_event(action, _params, socket) when action in ["increment", "reset"] do
    socket = load_session(socket)

    if socket.assigns.session_status == :ready do
      case PageState.update_counter(socket.assigns.session_id, action) do
        {:ok, count} -> {:noreply, assign(socket, count: count)}
        {:error, _reason} -> {:noreply, assign(socket, session_status: :unavailable)}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("theme_changed", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_info({:counter_changed, %{count: count}}, socket) do
    {:noreply, assign(socket, count: count)}
  end

  def handle_info(
        {:DOWN, ref, :process, _pid, _reason},
        %{assigns: %{session_monitor: ref}} = socket
      ) do
    # An idle page must not immediately recreate the process that just expired.
    {:noreply,
     assign(socket,
       count: 0,
       session_pid: nil,
       session_monitor: nil,
       session_status: :expired
     )}
  end

  defp load_session(socket) do
    session_id = socket.assigns.session_id

    with {:ok, pid} <- PageState.ensure_session(session_id),
         {:ok, count} <- PageState.read_counter(session_id) do
      socket = assign(socket, count: count, session_status: :ready)

      if connected?(socket) and socket.assigns.session_pid != pid do
        if socket.assigns.session_monitor,
          do: Process.demonitor(socket.assigns.session_monitor, [:flush])

        ref = Process.monitor(pid)

        case SessionProcess.subscribe(session_id, & &1.counter, :counter_changed, self()) do
          {:ok, _subscription} ->
            assign(socket, session_pid: pid, session_monitor: ref)

          {:error, _reason} ->
            Process.demonitor(ref, [:flush])
            assign(socket, session_status: :unavailable)
        end
      else
        socket
      end
    else
      {:error, _reason} -> assign(socket, session_status: :unavailable)
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <section class="mx-auto max-w-5xl px-6 py-16">
        <p class="text-sm font-semibold text-primary">PHOENIX APPLICATION STARTER</p>
        <h1 class="mt-4 text-4xl font-bold tracking-tight">Build your next workflow.</h1>
        <p class="mt-6 max-w-2xl text-lg text-on-surface-variant">
          LiveView for server interaction, Hologram for browser-side Elixir,
          and DuskMoon for a consistent interface. Add your domain here.
        </p>
        <div class="mt-10 grid gap-6 md:grid-cols-2">
          <section aria-labelledby="interaction-title" class="rounded-xl border border-outline-variant bg-surface-container p-6">
            <h2 id="interaction-title" class="text-xl font-semibold">Try session-backed state</h2>
            <p class="mt-3 text-on-surface-variant">
              This counter is shared across this browser session's refreshes and tabs.
              It expires after 30 idle minutes and is not stored in the database.
            </p>
            <p id="counter" aria-live="polite" class="my-6 text-4xl font-semibold">{@count}</p>
            <p :if={@session_status == :expired} id="session-expired" role="status" class="mb-4 text-on-surface-variant">
              Page state expired. Your next interaction starts a fresh session.
            </p>
            <p :if={@session_status == :unavailable} id="session-unavailable" role="alert" class="mb-4 text-error">
              Page state is temporarily unavailable. Try again shortly.
            </p>
            <div class="flex gap-3">
              <button id="increment" type="button" phx-click="increment" disabled={!connected?(@socket)} class="btn btn-primary">Increment</button>
              <button id="reset" type="button" phx-click="reset" disabled={!connected?(@socket)} class="btn btn-outline">Reset</button>
            </div>
          </section>
          <section aria-labelledby="next-title" class="rounded-xl border border-outline-variant bg-surface-container p-6">
            <h2 id="next-title" class="text-xl font-semibold">Make it yours</h2>
            <ol class="mt-4 list-inside list-decimal space-y-3 text-on-surface-variant">
              <li>Put business rules in contexts under Gsmlg.</li>
              <li>Keep durable data in Ecto and transient page state in session processes.</li>
              <li>Run the checks before building a release.</li>
            </ol>
            <a id="hologram-demo-link" class="btn btn-primary mt-6" href="/hologram-demo">Try browser-side Elixir with Hologram</a>
          </section>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
