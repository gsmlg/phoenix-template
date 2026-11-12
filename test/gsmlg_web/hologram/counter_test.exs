defmodule GsmlgWeb.Hologram.CounterTest do
  use ExUnit.Case, async: true

  alias GsmlgWeb.Hologram.Counter
  alias Hologram.Component
  alias Hologram.Server

  test "each component starts at zero independently" do
    first = Counter.init(%{}, %Component{}, %Server{})
    updated = Counter.action(:increment, %{}, first)
    second = Counter.init(%{}, %Component{}, %Server{})

    assert updated.state.count == 1
    assert second.state.count == 0
  end

  test "repeated actions and reset preserve unrelated component state" do
    component = Counter.init(%{}, %Component{state: %{other: :preserved}}, %Server{})
    component = Counter.action(:increment, %{}, component)
    component = Counter.action(:increment, %{}, component)
    assert component.state == %{count: 2, other: :preserved}

    component = Counter.action(:reset, %{}, component)
    assert component.state == %{count: 0, other: :preserved}
  end
end
