defmodule Gsmlg.Assets do
  @moduledoc "Shared configuration for the development watcher and production asset build."

  def watcher_options(profile, global, overrides \\ []) do
    tailwind = Keyword.fetch!(profile, :tailwind)
    server = Keyword.fetch!(profile, :server)

    [
      root: Keyword.fetch!(profile, :root),
      watch_dirs: Keyword.fetch!(server, :watch_dirs),
      tailwind: true,
      tailwind_css: Keyword.fetch!(tailwind, :css),
      tailwind_sources: Keyword.fetch!(tailwind, :sources),
      tailwind_outdir: Path.join(Keyword.fetch!(profile, :outdir), "css"),
      resolve_dirs: Keyword.fetch!(global, :resolve_dirs),
      target: Keyword.fetch!(global, :target)
    ]
    |> Keyword.merge(overrides)
  end
end
