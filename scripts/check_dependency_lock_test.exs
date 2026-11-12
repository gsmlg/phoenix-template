ExUnit.start()
Code.require_file("support/dependency_lock.exs", __DIR__)

defmodule Gsmlg.DependencyLockTest do
  use ExUnit.Case, async: true

  alias Gsmlg.DependencyLock

  test "accepts matching Hex entries with dependency options" do
    deps = [{:phoenix, "~> 1.8.15"}, {:igniter, "~> 0.8", only: [:dev, :test]}]
    lock = %{phoenix: {:hex, :phoenix, "1.8.15"}, igniter: {:hex, :igniter, "0.8.2"}}
    assert DependencyLock.errors(deps, lock) == []
  end

  test "reports all missing and incompatible direct entries" do
    deps = [{:phoenix, "~> 1.8.15"}, {:duskmoon_hologram, "~> 10.1.6"}]
    lock = %{phoenix: {:hex, :phoenix, "1.8.14"}}

    assert DependencyLock.errors(deps, lock) == [
             "phoenix: locked 1.8.14 does not satisfy ~> 1.8.15",
             "duskmoon_hologram: missing from mix.lock"
           ]
  end

  test "validates package aliases and lock source" do
    assert DependencyLock.errors([{:ui, "~> 1.0", hex: :ui_package}], %{
             ui: {:hex, :ui_package, "1.0.1"}
           }) == []

    assert [_] =
             DependencyLock.errors([{:ui, "~> 1.0"}], %{ui: {:hex, :wrong_package, "1.0.1"}})

    assert [_] = DependencyLock.errors([{:ui, "~> 1.0"}], %{ui: {:git, "url", "revision"}})
  end

  test "leaves explicit path and git dependencies to Mix" do
    deps = [{:local, path: "../local"}, {:remote, "~> 1.0", github: "example/remote"}]
    assert DependencyLock.errors(deps, %{}) == []
  end
end
