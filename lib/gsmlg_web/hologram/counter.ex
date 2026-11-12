defmodule GsmlgWeb.Hologram.Counter do
  use Hologram.Component
  prop(:page_mounted?, :boolean, from_context: {Hologram.Runtime, :page_mounted?})

  def init(_props, component, _server), do: put_state(component, count: 0)

  def template do
    ~HOLO"""
    <section>
      <p id="hologram-count" aria-live="polite" aria-atomic="true" class="text-4xl font-bold my-6">{@count}</p>
      <button id="hologram-increment" type="button" class="btn btn-primary" disabled={!@page_mounted?} $click="increment">Increment</button>
      <button id="hologram-reset" type="button" class="btn" disabled={!@page_mounted?} $click="reset">Reset</button>
    </section>
    """
  end

  def action(:increment, _params, component),
    do: put_state(component, count: component.state.count + 1)

  def action(:reset, _params, component), do: put_state(component, count: 0)
end
