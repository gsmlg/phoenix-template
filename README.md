# Phoenix Template

The shared UI design template and runnable reference implementation for our
applications, built with Phoenix, LiveView, Ecto, DuskMoon UI, DuskMoon Bundler,
and DuskMoon Hologram. It establishes common visual and interaction conventions
and provides the design specification other applications use to align their UI.

[DESIGN.md](DESIGN.md) is the authoritative design specification. It defines the
shared rules, distinguishes them from Phoenix-specific integration details, and
describes downstream adoption and verification. The runnable examples demonstrate
those rules; their implementation does not replace the specification.

The repository also serves as an application starter. Its identity remains
`:gsmlg` / `Gsmlg` / `GsmlgWeb`. Business rules belong in contexts rather than
in the rendering layer.

## Reference pages

Following Backplane's page architecture, Home uses `dm_page_header`
with an integrated Hero and scroll-aware navigation, without a sidebar. Introduction and demonstration pages use a primary appbar
above a contextual left menu and content area. The top bar switches sections;
the left menu opens topics and related examples.

| Page | Purpose |
| --- | --- |
| `/` | Introduces the five DuskMoon repositories and their roles |
| `/guidelines` | Shared specification, semantic token examples, and exact Markdown download |
| `/components` | Actual Core, Elements, Phoenix, and isolated React previews |
| `/use-cases` | Validated settings, filtered records, confirmation, and progress |
| `/use-cases/session` | Per-session state shared across tabs and refreshes |
| `/hologram-demo` | Browser-local state and offline actions |

`/ui` redirects to `/use-cases`. The specification download at
`/guidelines/DESIGN.md` is compiled into the application and includes an
`X-Design-Spec-SHA256` header. Consumer-source revisions and adaptation boundaries
are recorded in [design reference sources](docs/design-reference-sources.md).

The first edition remains under validation. The Elements input preview is blocked
by [upstream issue #90](https://github.com/duskmoon-dev/duskmoon-elements/issues/90).
See [validation status](docs/validation.md) for current evidence and historical checks.

## Development

Use the versions in `.tool-versions`: Elixir 1.18.4, OTP 28.1, Rust 1.99.1,
and Node.js 24.22.1. Elixir >= 1.18 and OTP >= 28 are required. Node.js is used
for lockfile tests and audits; DuskMoon Bundler performs the frontend build.
The npm manifest, lockfile, and installed dependencies live in the project root;
frontend source files and tests remain in `assets/`.
PostgreSQL 17 is the development database.

The current Vize 10.1.6 precompiled Linux NIF requires a newer glibc than the
supported container baseline. Build that dependency from source:

```sh
export VIZE_EX_BUILD=1
```

Keep this setting for dependency compilation in development and production.
Rust and a C/C++ compiler are build requirements, not release runtime requirements.
Do not concurrently compile the same dependency in dev and prod in one checkout.

Hex 2.7.0's published archive contains bytecode incompatible with OTP 28.
Build the official tagged source with the active toolchain:

```sh
git clone --depth 1 --branch v2.7.0 https://github.com/hexpm/hex.git /tmp/hex-source
(cd /tmp/hex-source && mix archive.build && mix archive.install hex-2.7.0.ez --force)
mix local.rebar --force
```

Use an unused temporary directory if `/tmp/hex-source` already exists.

```sh
mix setup
mix dev
```

Open http://localhost:4444. Start a local PostgreSQL instance before `mix setup`.
Database settings can be supplied with `PGHOST`, `PGPORT`, `PGUSER`,
`PGPASSWORD`, and `PGDATABASE` (development only). Tests use `PGDATABASE_TEST`
(default `gsmlg_test`), followed by `MIX_TEST_PARTITION` when set. A development
`PGDATABASE` is never reused by the test setup. Production uses `DATABASE_URL`.

## Rendering and assets

The reference pages use LiveView for server-connected interaction. `/hologram-demo`
uses DuskMoon Hologram for browser-side Elixir. Separate documents prevent the
two renderers from competing for the same DOM. The Hologram document shares the
DuskMoon stylesheet but does not load the LiveView JavaScript entry point.
Counter examples keep transient state; they are not persisted business features.
Development and production Hologram builds share generated static output. After
a production build, restart `mix dev` before browser verification so its runtime
manifest and generated files match again.

Use `mix dev` in development. It runs `mix holo`, starting Phoenix with Hologram
enabled (equivalent to `HOLOGRAM_START=1 mix phx.server`). The fork's
configuration namespace is `:duskmoon_hologram`; public modules remain
`Hologram.*` and the compiler is `:hologram`. Do not also install upstream
`:hologram`. Releases explicitly set `HOLOGRAM_ENV=prod`.

DuskMoon Bundler owns the development watcher and `mix assets.build` /
`mix assets.deploy`. The deploy alias defaults to `MIX_ENV=prod` and includes
the isolated React stylesheet entry. Tailwind and DuskMoon semantic tokens are used throughout.
Keep the sunshine/moonlight themes working. There is no Yarn or esbuild build path.

## Checks

```sh
elixir scripts/check_dependency_lock_test.exs
elixir scripts/check_dependency_lock.exs
mix format
mix precommit
mix assets.setup
npm test
npm audit --omit=dev --audit-level=high
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix compile --warnings-as-errors
MIX_ENV=prod mix release
git diff --check
```

The dependency lock preflight requires only Elixir/OTP. It checks direct Hex
requirements before CI or Docker downloads anything; Mix still verifies
transitive resolution and integrity. After an intentional dependency change,
run `mix deps.get` with registry access and commit the generated `mix.lock`.
Never edit package checksums by hand.

The CI workflow runs PostgreSQL-backed tests, dependency checks, production
asset compilation, release creation, and a Docker build without publishing.
These workflow definitions are not evidence that a remote run has passed.
Verify desktop rendering, theme switching, repeated interactions, reconnects,
and CSS/JS requests after web-facing changes. A successful audit does not prove
application security.

The application's npm lockfile is committed. Hologram 10.1.6's published package
does not include its internal JavaScript lockfile and resolves those dependencies
during compilation. That upstream reproducibility limitation is separate from
the application lockfile audit. Do not flatten dependency versions using overrides
without compatibility validation.

## Production releases

The Dockerfile uses matching Debian bookworm build/runtime stages and builds
Vize locally. The final image contains the Mix release, runs as a non-root user
on port 4000, and does not include Rust or embedded application credentials.

```sh
docker build -t phoenix-template .
```

Provide `DATABASE_URL`, a strong `SECRET_KEY_BASE`, and `PHX_HOST` at runtime.
Optional settings include `PORT`, `POOL_SIZE`, `ECTO_IPV6`, and
`DNS_CLUSTER_QUERY`. The container sets `PHX_SERVER=true`. Configure TLS
termination, readiness checks, restart policy, and backups in the deployment
platform. Use a database-readiness probe appropriate to your deployment.

Migrations are an explicit deployment step, never an application-startup effect:

```sh
_build/prod/rel/gsmlg/bin/gsmlg migrate
PHX_SERVER=true _build/prod/rel/gsmlg/bin/gsmlg start
```

The public Unix release launcher supports `bin/gsmlg {start,daemon,migrate}`.
Run `bin/gsmlg help` (or `--help`, `-h`, or no arguments) for usage.
A custom post-assembly step retains the generated Mix launcher as
`bin/gsmlg.runtime` and installs a thin dispatcher as `bin/gsmlg`. All commands
other than migrate/help are forwarded unchanged with `exec`, including start
and daemon. `bin/migrate` remains a compatibility alias.
It resolves its sibling release launcher independently of the current directory,
runs all pending migrations using `Gsmlg.Release.migrate/0`, and propagates failures
as a nonzero exit status. It starts the repository through `Ecto.Migrator.with_repo/2`,
not the web application. Supply the same runtime environment listed above.

For the container, override its command with `/app/bin/gsmlg migrate`:

```sh
docker run --rm --env-file production.env phoenix-template /app/bin/gsmlg migrate
```

Run migrations
once per deployment after backup/review, not independently on every replica.
`Gsmlg.Release.rollback(Gsmlg.Repo, version)` is available for a deliberate,
reviewed rollback. `restart_prod.sh` only wraps release lifecycle commands.

## Extending the starter

- Put domain rules in `lib/gsmlg` and web adapters in `lib/gsmlg_web`.
- Prefer verified routes, context functions, migrations, and focused tests.
- Keep production secrets in runtime environment variables.
- Igniter is a dev/test-only tool for compatible installers.
- Add authentication, jobs, storage, and other services when the product needs them.

See [the rebuild notes](docs/template-rebuild.md) for boundaries and migration guidance.

## UI component recipes

Visit `/ui` for interactive Phoenix DuskMoon form, button, card, badge,
confirmation, search and progress examples. See [UI recipes](docs/ui-examples.md)
for source locations, state boundaries and verification status.
