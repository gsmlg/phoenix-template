# Validation status

The sections dated 2026-11-11 and 2026-11-12 below are historical checkpoints.
Design-reference v1 evidence is recorded in the 2026-11-14 section.
The 2026-11-15 section records the subsequent page architecture changes.

This checkout continues the reconstructed implementation at `5f8b068`. The
original pre-reset uncommitted implementation was not recovered. It is a
work-in-progress checkpoint, not a verified release.

Checked on 2026-11-11:

- The saved Git bundle was restored separately and verified, including its
  complete history and `5f8b068` commit. The current checkout already matched it,
  so no working files were overwritten.
- Elixir 1.18.4 with OTP 28.1 runs successfully. Exact 1.18.0/28.0 was not run.
- Four dependency-independent RuntimeRequirements ExUnit tests pass.
- Two asset configuration tests pass, including matching development watcher
  source patterns and resolver settings to the production Bundler profile.
- Two test-database configuration tests pass, including isolation from a
  development `PGDATABASE` and partition suffixes on custom test names.
- Four direct-dependency lock checker tests pass. The real project preflight
  correctly fails on the six unresolved entries listed below.
- Ten Node dependency-integrity and theme tests pass, including the initial
  document theme script under blocked storage.
- Seven Playwright tests are collected successfully. Collection is not a browser
  execution result.
- Elixir syntax parsing, JavaScript syntax, YAML parsing, shell syntax and
  `git diff --check` pass.
- Official Phoenix Session Process `1.0.1` source was reviewed for reducer,
  startup, subscription, Plug, ordering and expiry APIs. This is not a substitute
  for compilation and runtime integration tests.
- Official DuskMoon Bundler `v10.1.6` APIs were checked for watcher, DevServer,
  build flags, frozen npm install and static paths. The development watcher now
  derives its Tailwind source patterns and resolver settings from the shared
  production profile rather than a broader fallback scan.

Blocked or not run:

- Previous Hex and npm requests were denied with proxy HTTP 403. This pass did
  not retry those denied downloads or change network controls. Dependency cache
  is absent. Offline `mix precommit` and `MIX_ENV=prod mix assets.deploy`
  both stop before compilation, tests, or asset generation.
- `mix.lock` still has Ecto 3.14.2 instead of the required >= 3.14.3 within 3.14;
  Phoenix DuskMoon, DuskMoon Bundler and its runtime are still 9.14.0 instead of
  their declared 10.1 requirements. DuskMoon Hologram and Phoenix Session Process
  are missing entirely. The lockfile MUST be regenerated through Mix.
- npm audit has not run successfully. No clean security audit is claimed.
- Added SessionProcess concurrency/isolation tests and Hologram state tests are
  not runtime-verified because Mix dependencies are unavailable.
- Full `mix precommit`, `assets.deploy`, Hologram compilation, browser execution
  and production release have not passed for this reconstruction.
- The cloud environment has no `docker` executable, so no Docker build ran.
- Dependency-independent Elixir formatting was run; the project's full formatter
  and HEEx plugin require downloaded dependencies and still need to run.

Resume in a permitted environment with access to official package registries:
complete `mix deps.get`, rerun the lock preflight, then run `mix setup`,
`mix precommit`, npm tests/audit, browser tests, production assets/release and
Docker checks. Keep native dependency builds serial. These are local validation
results; publishing this checkpoint does not make it a verified release.

## Release migration command (2026-11-12)

Added executable `rel/overlays/bin/migrate`, included in Mix releases as
`bin/migrate`. Its dependency-independent shell contract tests verify invocation
from an unrelated directory, a path containing spaces, argument rejection, and
propagation of the release launcher's exit status. These tests use a fake launcher;
they do not verify real database migrations. Production release assembly and a
PostgreSQL migration smoke test remain blocked by the dependency-lock issues above.

### Unified release command

The public Unix entrypoint is now `bin/gsmlg {start,daemon,migrate}` with
help on no arguments, `help`, `-h` and `--help`. The unchanged generated Mix
launcher is retained as `bin/gsmlg.runtime`; native commands are exec-forwarded.
Shell tests cover help, argument preservation, migration dispatch, compatibility
alias and exit status. A temporary dependency-free Mix release, built with the
exact post-assembly function, successfully executed help, version, and migration
dispatch in a real release VM. Its migration function was a stub, so this is not
a PostgreSQL integration test or a successful build of the full template.

## UI recipe page (2026-11-12)

Added `/ui`, navigation and Phoenix DuskMoon button/alert element registration.
Component attrs/slots were checked against the upstream source linked in
`ui-examples.md`. Elixir source parsing/formatting, JavaScript syntax, existing
Node tests and `git diff --check` pass. LiveView and browser cases were added for
form errors/success, search empty-state recovery, confirmation cancel/restore,
progress and reload. They have not executed: full Mix compilation still stops on
missing dependencies and the existing inconsistent lock. No browser/rendered UI
or accessibility acceptance is claimed.

## Design reference v1 (2026-11-14)

This section supersedes the older dependency and execution blockers above for
this local checkout. The page architecture and build are implemented, but v1 is
not fully accepted while the Elements input regression remains unresolved.
No commit, push, remote CI run, publication, or deployment was performed.

Implemented routes are `/`, `/guidelines`, `/components`, `/use-cases`,
`/use-cases/session`, and `/hologram-demo`; `/ui` redirects to `/use-cases`.
The isolated React document is `/previews/react`. All project-authored copy is
English. The five upstream design repositories and four public consumer patterns
are recorded with immutable references in `design-reference-sources.md`.

Verified locally:

- `mix setup` completed, including the frozen frontend dependency installation.
- `mix precommit` passed: 35 ExUnit tests, formatting, warnings-as-errors, and
  unused-lock checks. Checks used Elixir 1.18.4 on OTP 28.5.0.1. The default local
  Elixir 1.20.4 still reports a generated Phoenix.SessionProcess unused-clause
  warning; it was not silently suppressed or patched.
- Ten frontend dependency/theme tests passed. The direct Hex lock preflight
  passed, and the npm lockfile installation reported zero vulnerabilities.
- `mix assets.build` and production `mix assets.deploy` passed through
  DuskMoonBundler. The deploy alias now prefers the production environment so
  its isolated React CSS entry is included.
- `MIX_ENV=prod mix compile --warnings-as-errors` and `mix release --overwrite`
  passed on macOS ARM64. Production native dependencies were built serially.
- A release VM launched from `/tmp` verified the embedded specification hash,
  started the application without an HTTP listener, and exercised the preview
  and both stylesheet requests through the release Endpoint. All returned 200;
  both stylesheets had the CSS MIME type, and the isolated stylesheet resolved
  through the production manifest to its hashed asset.
- The canonical specification hash was
  `006de7de243471e9a5dd455d33b10d6aaad85c7cc351713ad98a339edbae6de9`.
  The download is also checked byte-for-byte against `DESIGN.md` in ExUnit and
  the browser suite. Release execution does not require that file in its
  working directory.
- A browser instrumentation pass observed 88 unique registered custom elements
  with no missing definitions. Registration does not imply every control's
  behavior is accepted; the input failure below is explicitly retained.
- Desktop verification used Chrome at `http://localhost:4444`, with the default
  Desktop Chrome viewport and 1440×1000 screenshots in sunshine and moonlight.
  No mobile or complete accessibility audit is claimed.
- Final desktop browser suite: 13 passed, 1 failed. The sole failure is the
  unskipped Elements input regression for issue #90. Navigation, specification
  download, Core/Phoenix/React actions, settings and filtering, both themes,
  session sharing and reconnect, Hologram offline actions, history navigation,
  security headers, asset loading, and longpoll fallback passed.
- React CSS is confined to its preview document. Both themes preserve readable
  parent neutral outlined badges, and parent/iframe primary tokens match.
- `git diff --check` passed. Generated assets, dependencies, releases, screenshots,
  and traces remain ignored and uncommitted.

A follow-up focused browser check also passed for the Elements switch: pointer
toggling, a keyboard Space change after focus, and state retention across an
unrelated LiveView counter update. This added one regression case; it was run
separately from the 13-pass/1-failure full-suite result above. The Elements issue
remained open and the latest published aggregate version remained 1.10.3 at the
follow-up check. No fixed release was available to adopt.

### Remaining acceptance gates

- **Blocker — Elements input focus:**
  [duskmoon-dev/duskmoon-elements#90](https://github.com/duskmoon-dev/duskmoon-elements/issues/90).
  The 1.10.2 input replaces its Shadow DOM control on focus, dropping focus before
  typing. Published 1.10.3 source retains that behavior. The page carries a
  limitation notice and the regression test is deliberately not skipped or
  marked as an expected failure. Acceptance resumes after a fixed aggregate
  release is installed and the interaction passes; no local control replacement
  or dependency patch bypasses it.
- **Needed — Bundler CSS vendor handling:**
  [duskmoon-dev/duskmoon-bundler#27](https://github.com/duskmoon-dev/duskmoon-bundler/issues/27).
  A supported, explicitly tracked temporary integration serves the dedicated
  CSS source directly in development and emits a first-class CSS entry in
  production. It references the aggregate package's published stylesheet.
  The comments in `assets/css/react_preview.css` and `config/prod.exs` identify
  the removal condition. Development, production manifest, and release checks
  cover this integration.
- Docker image execution remains unverified: the installed client cannot connect
  to its Colima daemon socket. The Dockerfile copies `DESIGN.md` before compiling,
  but native release evidence is not Linux container evidence.

### Reproducing browser checks

Complete production builds before the final development browser pass, then
restart `mix dev`. Hologram's development and production outputs share
`priv/static`, and a still-running development process can retain runtime hashes
removed by a subsequent production build. Confirm fresh runtime URLs return 200.
Screenshots and traces go to `_build/browser-tests`, outside the asset watcher.

```sh
PLAYWRIGHT_BASE_URL=http://localhost:4444 \
PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
npm run test:browser -- --workers=1
```

## Page architecture (2026-11-15)

Home now uses `Layouts.home` and the actual `dm_page_header` component: an
integrated navigation/Hero, semantic gradient, centered heading and entry
points, and floating navigation after scrolling. Introduction pages use
`Layouts.app` with a full-width `dm_appbar` above a contextual `dm_left_menu`
and content area. The Hologram document follows the same application hierarchy.
The specification and source notes describe the two distinct shells in English.

Verified in the current local checkout:

- `mix precommit`: 36 tests passed with Elixir 1.18.4 / OTP 28.5.0.1.
- `mix assets.deploy`: passed, including the aggregate JS entries, shared CSS,
  isolated React stylesheet, and digested assets.
- Production compilation with `--warnings-as-errors`: passed after the final
  canonical specification edit.
- Desktop Chrome at `http://localhost:4444/`: 16 of 17 Playwright tests passed.
  Home's PageHeader/floating navigation and theme controls, contextual topic
  links, Session/Hologram navigation, sticky desktop geometry, both themes,
  document/CSS/JS requests, LiveView connectivity, and canonical specification
  export passed. Screenshots of both themes were visually inspected.
- Corrected secondary-navigation text inheritance and hover colors; both themes
  assert that unselected menu links use the navigation's semantic text color.
- `git diff --check`: passed.

The only browser failure remains the existing Elements input focus/value
regression tracked in [duskmoon-elements #90](https://github.com/duskmoon-dev/duskmoon-elements/issues/90).
It remains an active failing test. No dependency workaround was introduced.
The development service was restarted after production compilation to refresh
Hologram's generated runtime assets and is available on port 4444. No mobile,
new release assembly, Docker image, remote CI, commit, or push is claimed for
this page-architecture change.

## Commit preparation (2026-11-16)

Aligned the CI readiness URL and Playwright default base URL with port 4444,
and aligned failure artifact collection with `_build/browser-tests`. Re-ran
`mix precommit` (36 tests passed), frontend Node tests (10 passed), configuration
consistency checks, and `git diff --check`. Production asset and desktop browser
evidence remains the 2026-11-15 checkpoint above; the known Elements #90 test
is still enabled and prevents a fully green browser suite.
