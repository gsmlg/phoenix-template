defmodule GsmlgWeb.Hologram.Counter do
  use Hologram.Component
  use Hologram.JS

  @storage_key "gsmlg.hologram.counter"

  prop(:page_mounted?, :boolean, from_context: {Hologram.Runtime, :page_mounted?})

  def init(_props, component, _server) do
    component
    |> put_state(count: 0)
    |> put_action(:restore)
  end

  def template do
    ~HOLO"""
    <section>
      <p id="hologram-count" aria-live="polite" aria-atomic="true" class="text-4xl font-bold my-6">{@count}</p>
      <button id="hologram-increment" type="button" class="btn btn-primary" disabled={!@page_mounted?} $click="increment">Increment</button>
      <button id="hologram-reset" type="button" class="btn" disabled={!@page_mounted?} $click="reset">Reset</button>
    </section>
    """
  end

  def action(:restore, _params, component) do
    stored_count =
      JS.eval("""
      (() => {
        try { return localStorage.getItem("#{@storage_key}") ?? ""; }
        catch { return ""; }
      })()
      """)

    count =
      case Integer.parse(stored_count) do
        {count, ""} when count >= 0 -> count
        _ -> 0
      end

    put_state(component, count: count)
  end

  def action(:increment, _params, component),
    do: save_count(component, component.state.count + 1)

  def action(:reset, _params, component), do: save_count(component, 0)

  defp save_count(component, count) do
    JS.exec("""
    try { localStorage.setItem("#{@storage_key}", "#{count}"); }
    catch { /* The counter remains usable when storage is unavailable. */ }
    """)

    put_state(component, count: count)
  end
end
