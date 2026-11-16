# Design Reference V1 Implementation Plan

**Goal:** Deliver an English shared design reference with an introduction to the five DuskMoon repositories, real component previews, application-derived use cases, and a downloadable canonical specification.

**Architecture:** Four primary routes (Overview, Guidelines, Components, Use Cases) share a navigation shell. Session and Hologram examples remain executable under the use-case hierarchy. React runs in a separate preview document. Repository and application provenance is explicit; sample data is synthetic.

**Tech stack:** Phoenix LiveView, PhoenixDuskmoon, DuskMoon Core and Elements, DuskMoonBundler, and an isolated React adapter preview. Preserve `:gsmlg`, all-element registration, themes, and port 4444.

## Execution boundaries

Work in the current main checkout. Preserve pre-existing edits and deletions. No commits, pushes, deployment, branches, worktrees, or upstream code edits. Research repositories are read-only. Serialize shared build and dependency installation operations.

## Tasks and acceptance

- [x] Inspect all five upstream repositories and at least three actual consumer patterns. Record source revisions and immutable links in `docs/design-reference-sources.md`.
- [x] Build `Gsmlg.DesignCatalog` with repository roles and source metadata; replace the starter homepage with the ecosystem introduction.
- [x] Update `Layouts.app` and shared reference components for active navigation, breadcrumbs, section headings, theme controls, and consistent content width.
- [x] Expose Guidelines and a downloadable `DESIGN.md` from one canonical source. Verify the export equals the source and survives release packaging.
- [ ] Add Components with live Core, Elements, Phoenix, and isolated React previews, usage snippets, and source attribution. Verify interactions and component registration in a browser.
- [x] Rework the existing examples into practical Use Cases informed by consumer code: workspace settings, searchable records, confirmation, and job progress. Preserve validation, empty-state recovery, cancellation, reset, and truthful demo persistence.
- [x] Move the session counter to `/use-cases/session`; retain the Hologram route with shared visual navigation. Update regression tests for both lifecycles and cross-renderer navigation.
- [x] Keep `/ui` as a redirect to `/use-cases`. Verify deep links and all primary navigation routes.
- [x] Run `mix precommit`, frontend tests, `mix assets.deploy`, and `git diff --check`. Use CI-compatible Elixir for ExUnit and the running development server's toolchain for development assets.
- [ ] Run desktop browser checks at port 4444 for navigation, each preview, realistic use-case interactions, both themes, spec export, and console/network health. Inspect screenshots; do not claim mobile acceptance.
- [x] Review the combined diff, update the implementation documentation and verification evidence, and audit the complete goal before stopping.

## Ownership

The coordinator owns catalog data, homepage, shared layout/styles, guidelines/export, routing, session migration, integration, and final verification. Parallel workers may own separate component-preview and use-case modules after source research; shared dependency installation, router changes, Git operations, and builds remain coordinated.

## Acceptance gate discovered during execution

Elements input focus is blocked by `duskmoon-dev/duskmoon-elements#90`. The
installed 1.10.2 input replaces its shadow control on focus; the published 1.10.3
implementation retains the same behavior. Keep the input regression test failing,
report the limitation in the Components page, and do not mark v1 fully accepted
until a fixed aggregate release passes it. Other adapter and workflow checks
continue independently.

## Final local verification

35 ExUnit and 10 frontend tests pass. Production assets, warnings-as-errors
compilation, native release assembly, release specification export, and release
preview/CSS endpoint checks pass. The final desktop browser suite has 13 passes
and one unskipped failure for Elements #90. Bundler #27 has a linked, verified
CSS-entry integration and a removal condition. Docker execution is unverified
because its daemon is unavailable. The two browser/component acceptance items
remain unchecked deliberately; v1 is not fully accepted. No commit or push.

A focused follow-up Elements switch regression passed for pointer and keyboard
changes and state retention across unrelated LiveView updates. Input acceptance
remains blocked: issue #90 is open and the latest aggregate release is still
1.10.3. No dependency change or local input workaround was applied.
