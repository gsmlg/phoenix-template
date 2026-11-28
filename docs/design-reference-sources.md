# Design Reference V1 Sources

The design references were reviewed on 2026-11-14. The Web package sources
were updated to the consolidated release on 2026-11-21. Examples use synthetic
data from the referenced patterns.

## Five Layers

| Repository | Role | Reviewed source |
| --- | --- | --- |
| `duskmoon-dev/design` | YAML design tokens, generated CSS/JSON/TypeScript/Dart outputs, and the shared design vocabulary | [README](https://github.com/duskmoon-dev/design/blob/175c49dd86d173bf3bba5d8ca6a647ad42421a0f/README.md) |
| `duskmoon-dev/duskmoon-web` | Framework-neutral Core CSS, semantic tokens, themes, and Tailwind integration | [Core](https://github.com/duskmoon-dev/duskmoon-web/blob/v2.0.0-rc.3/packages/css/core/README.md) |
| `duskmoon-dev/duskmoon-web` | Native custom elements with browser-owned behavior and Shadow DOM | [Elements](https://github.com/duskmoon-dev/duskmoon-web/blob/v2.0.0-rc.3/packages/elements/elements/README.md) |
| `duskmoon-dev/duskmoon-web` | React components exposed through `@duskmoon-dev/components` | [React Components](https://github.com/duskmoon-dev/duskmoon-web/blob/v2.0.0-rc.3/packages/react/components/README.md) |
| `duskmoon-dev/duskmoon-web` | Phoenix HEEx components, LiveView integration, and hooks | [Duskmoon Phoenix](https://github.com/duskmoon-dev/duskmoon-web/blob/v2.0.0-rc.3/phoenix/apps/duskmoon_phoenix/README.md) |

The runnable template pins Core, Elements, React Components, and both
`duskmoon_phoenix` distributions to Duskmoon Web 2.0.0-rc.3. The Design repository
and Bundler toolchain follow their own release schedules. `package-lock.json`
and `mix.lock` record the resolved versions. Component imports use aggregate
packages, and their individual dependencies are installed transitively.

## Application-Derived Patterns

| Reference | Pattern adapted | What this template does |
| --- | --- | --- |
| [Sigma hook settings](https://github.com/gsmlg-opt/sigma/blob/f19cfae16d9e4c0040ab041c15a394edf95a9534/apps/sigma_web/lib/sigma_web/live/hooks_settings_component.ex#L131) | Labeled settings, validation, save, and cancel | A workspace name form validates input and restores its last locally saved value on cancel. |
| [Backplane memory records](https://github.com/gsmlg-opt/backplane/blob/3be870e3bbcd08a332aeda90f9438b1363b95b8a/apps/backplane_admin/lib/backplane/admin/live/memory_records_live.ex#L106) | Query/status filtering, empty results, selection and detail | Three synthetic records demonstrate filtering, recovery, and guarded selection. |
| [Backplane host services](https://github.com/gsmlg-opt/backplane/blob/3be870e3bbcd08a332aeda90f9438b1363b95b8a/apps/backplane_admin/lib/backplane/admin/live/host_services_live.ex#L160) | Editing, cancellation, and explicit destructive confirmation | A sample record can be removed only after confirmation, then restored for repeated practice. |
| [Backplane jobs](https://github.com/gsmlg-opt/backplane/blob/3be870e3bbcd08a332aeda90f9438b1363b95b8a/apps/backplane_admin/lib/backplane/admin/live/logs_jobs_live.ex#L53) | Status badges and operational feedback | A manually advanced four-step job illustrates bounded progress and reset. Percent progress is a synthetic adaptation, not an upstream behavior claim. |

The form and list examples keep state only for the current LiveView. They do not
write a database or call the referenced products. The session example uses the
existing session process, while the Hologram example runs in the browser.

## Backplane Page Architecture (2026-11-15)

The shell follows the locally reviewed Backplane revision
`3be870e3bbcd08a332aeda90f9438b1363b95b8a`:

- `apps/backplane_api/lib/backplane/api/controllers/page_html/home.html.heex`:
  a public home page with a primary `dm_appbar` above its content.
- `apps/backplane_admin/lib/backplane/admin/components/layouts/app.html.heex`:
  a full-width appbar with top-level navigation, followed by a contextual
  `dm_left_menu` and the main content area.

This template maps that hierarchy to its reference sections. Per the reference
UI direction, Home uses `dm_page_header` with a centered Hero and scroll-aware
navigation, rather than Backplane's public-home `dm_appbar`. Home has no left
menu; other pages expose section topics and demonstrations in the left menu.
The menu remains CSS-sticky and uses DuskMoon's built-in collapsible component
and hook on LiveView pages. It changes from a 16rem menu to a 4.5rem icon rail,
and the content area receives the released width. A fixed toggle stays outside
the scrolling menu body. The browser preference `gsmlg.navigation.collapsed`
is shared across page loads and renderers; unavailable storage leaves in-page
toggling usable. Backplane's persistent child LiveView and application-specific
navigation state are not copied. Hologram uses its own component lifecycle,
the same central menu data and DuskMoon icons, and native hint popovers. It
does not load LiveSocket or manually mount LiveView hooks.

## Routes and Ownership

| Route | Purpose | Runtime |
| --- | --- | --- |
| `/` | Repository introduction and entry points | LiveView |
| `/guidelines` | Canonical design specification and token examples | LiveView |
| `/guidelines/colors` | Semantic color examples | LiveView |
| `/guidelines/specification` | Canonical design specification | LiveView |
| `/guidelines/DESIGN.md` | Exact compiled specification download with SHA-256 header | Controller |
| `/components` | Core, Elements, Phoenix, and React compositions | LiveView, with isolated React iframe |
| `/components/core`, `/components/elements`, `/components/phoenix`, `/components/react` | One selected integration per route | LiveView, with isolated React iframe on React |
| `/previews/react` | Actual React adapter and local state | Separate HTML document and JS entry |
| `/use-cases` | Practical workflow compositions and source attribution | LiveView |
| `/use-cases/workspace-settings`, `/use-cases/records`, `/use-cases/confirmation`, `/use-cases/progress` | One selected workflow per route | LiveView |
| `/use-cases/async-data` | Initial page shell, background data loading, and retry | LiveView async assigns |
| `/use-cases/react-chat` | React chat composer and transcript with scripted replies | LiveView and mounted React |
| `/use-cases/react-form` | React form generated from JSON Schema with validated submissions | LiveView and mounted React |
| `/use-cases/settings` | Object settings identity and General profile draft | LiveView |
| `/use-cases/settings/github` | GitHub integration draft | LiveView |
| `/use-cases/settings/appearance` | Auto, Light, and Dark preferences | LiveView |
| `/use-cases/session` | Shared per-session state, expiry, and reconnect behavior | LiveView and Session Process |
| `/hologram-demo` | Browser-local actions and reload lifecycle | Hologram |
| `/ui` | Compatibility redirect to `/use-cases` | Controller |

Every contextual left-menu destination uses a distinct path with matching content,
page title, and active state. Introduction routes retain the complete overview;
topic routes show only their selected topic. Settings section links patch between
path routes to retain independent drafts. Legacy `?section=` bookmarks are replaced
with their corresponding paths.

The standalone React preview loads package CSS before the shared stylesheet.
The React form on `/components/react` loads the same package CSS inside a shadow
root and inherits theme tokens from the host. The hook owns the form subtree,
and LiveView validates submissions and displays the received values outside it.
The two React use cases reuse this mount. Chat keeps its transcript in React and
receives scripted replies from LiveView. The form renders the schema supplied by
LiveView and displays the validated submission as JSON.

The settings page adapts the supplied object-settings layout: identity above a
local section menu and content panel. General and GitHub integration use synthetic,
page-local data; saving does not authorize an account or call GitHub. Appearance
is a browser preference and persists separately from those example forms.
Application Appbars keep navigation beside the brand on the left and have no
theme selector. The home PageHeader retains its dropdown. Appearance's Auto,
Light, and Dark controls share the `theme` preference (`default`, `sunshine`, or
`moonlight`); the cookie carries only the resolved theme for server rendering.
Hologram initializes the same theme module through its JS interop after mounting,
without LiveSocket, so Auto and cross-tab changes also work in its separate document.

The specification is embedded at compile time, so the release does not need a
working-directory `DESIGN.md`. The download remains byte-for-byte identical to
the canonical file used to compile that release. It is a working export until
an authorized commit or release establishes a published source revision.

## Asset Pipeline Integration

The stylesheet entry split is a temporary, supported-pipeline integration for
[Bundler issue #27](https://github.com/duskmoon-dev/duskmoon-bundler/issues/27):
the development vendor optimizer incorrectly sends CSS imports to the JS bundler.
Development serves `assets/css/react_preview.css` directly. Production adds that
CSS file as a first-class entry; `mix assets.deploy` defaults to the production
environment so the standalone stylesheet is always emitted for deployment.
The source references only the aggregate package's published stylesheet. Remove
the relative artifact reference and environment split when a fixed Bundler
release supports public CSS imports in both paths, then rerun the same checks.

Sidebar storage checks deny reads and writes for `gsmlg.navigation.collapsed`
while preserving storage used by other application features. Completely denying
access to `window.localStorage` exposes an existing LiveSocket constructor failure
before sidebar hooks mount (`deps/phoenix_live_view/assets/js/phoenix_live_view/live_socket.ts:391`
in the installed dependency). That application bootstrap issue remains outside
the sidebar change; these checks do not establish operation with all browser
storage disabled.
