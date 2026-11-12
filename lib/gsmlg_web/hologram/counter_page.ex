defmodule GsmlgWeb.Hologram.CounterPage do
  use Hologram.Page
  alias GsmlgWeb.Hologram.Counter
  route("/hologram-demo")
  layout(GsmlgWeb.Hologram.Layout)

  def template do
    ~HOLO"""
    <main class="max-w-3xl mx-auto p-8">
      <a href="/" class="link">Back to LiveView</a>
      <h1 class="text-3xl font-bold mt-6">Hologram counter</h1>
      <p>Actions run in your browser. This counter resets on a page reload.</p>
      <Counter cid="counter" />
    </main>
    """
  end
end
