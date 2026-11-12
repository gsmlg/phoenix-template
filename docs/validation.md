# Rebuild validation status

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
