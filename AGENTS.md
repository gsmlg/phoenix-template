# Repository Instructions

## Scope

This repository is a Phoenix application template. Keep the template
generatable, runnable, and easy to extend. Preserve the `:gsmlg` application
name unless a task explicitly changes the template identity.

## Phoenix and Elixir

- Target Elixir 1.18+ and Phoenix 1.8+ APIs.
- Use `Phoenix.Component`, `embed_templates`, and `~p` verified routes.
- Keep application runtime configuration in `config/runtime.exs`; production
  secrets must come from environment variables.
- Use plain functions for stateless helpers. Add processes only for runtime
  state, concurrency, or fault isolation.
- Keep Ecto access behind `Gsmlg.Repo` and use the existing test helpers for
  database-backed tests.

## DuskMoon UI and assets

- Build assets through DuskMoonBundler. Use `mix assets.build` for development
  output and `mix assets.deploy` for digested production output.
- Keep the profile name `:gsmlg` consistent across `config/config.exs`, the
  development watcher, and `DuskmoonBundler.static_path/3` calls.
- Use DuskMoon semantic tokens such as `bg-primary`, `bg-surface`,
  `text-on-surface`, and `text-primary-content`; do not add hardcoded palette
  colors to HEEx or CSS.
- Keep `sunshine` and `moonlight` theme behavior working when changing the
  application shell or assets.
- Do not commit `assets/node_modules`, `_build`, `deps`, or generated
  `priv/static` files.

## Dependencies and generators

- Use `mix setup` after dependency or database changes.
- Igniter is a development/test-only extension mechanism. Use
  `mix igniter.install` for libraries that provide an installer; do not add
  Igniter to production runtime dependencies.
- Prefer npm through the Mix aliases (`mix assets.setup` and `mix assets.build`)
  rather than introducing another JavaScript package manager.

## Verification

Before handing off a change, run the smallest relevant checks. For template,
runtime, or asset changes, run:

```sh
mix precommit
mix assets.deploy
git diff --check
```

For web-facing changes, verify the desktop page at `http://localhost:4000/`
and check that the document, CSS, JS, and LiveView requests succeed without
browser console errors. Do not claim mobile or responsive validation unless it
was explicitly requested.

Keep changes focused. Do not rewrite the legacy deployment scripts or Docker
image as part of a UI/template change unless the task explicitly includes
deployment migration.
