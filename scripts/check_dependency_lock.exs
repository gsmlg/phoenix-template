# Run with `elixir scripts/check_dependency_lock.exs` before fetching or compiling.
# No dependencies, package registries, or network access are needed.
Code.require_file("support/dependency_lock.exs", __DIR__)
Mix.start()

File.cd!(Path.expand("..", __DIR__), fn ->
  Code.require_file("mix.exs")
  lock = Mix.Dep.Lock.read()

  case Gsmlg.DependencyLock.errors(Mix.Project.config()[:deps], lock) do
    [] ->
      IO.puts("Direct Hex dependency declarations match mix.lock.")

    errors ->
      IO.puts(:stderr, "Dependency lock preflight failed:")
      Enum.each(errors, &IO.puts(:stderr, "  - " <> &1))
      IO.puts(:stderr, "Run mix deps.get with authorized registry access and commit mix.lock.")
      System.halt(1)
  end
end)
