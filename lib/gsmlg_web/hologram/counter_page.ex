defmodule GsmlgWeb.Hologram.CounterPage do
  use Hologram.Page
  alias GsmlgWeb.Hologram.Counter
  route("/hologram-demo")
  layout(GsmlgWeb.Hologram.Layout)

  def template do
    ~HOLO"""
    <div class="design-page">
      <p class="design-eyebrow">USE CASE / BROWSER-LOCAL STATE</p>
      <h1 class="design-title">State in your browser.</h1>
      <p class="design-lead">Actions run in your browser.</p>
      <p class="mt-3 text-sm text-on-surface-variant">The counter saves each change to <code>localStorage</code> and restores the saved value when the page loads.</p>
      <section class="design-section design-preview"><div class="design-preview-body"><Counter cid="counter" /></div></section>
      <p class="text-sm text-on-surface-variant">After the runtime loads, these actions also work offline. Use session state for live synchronization across tabs.</p>
    </div>
    """
  end
end
