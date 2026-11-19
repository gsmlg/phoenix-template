# Shared UI Design Specification

This repository is our shared UI design template and runnable reference
implementation. This document is the authoritative specification that other
applications adopt to align their UI. The goal is a clear, restrained, usable
interface with consistent colors, components, and interactions across applications.

The specification and reference implementation have complementary roles:

| Layer | Responsibility | Downstream use |
| --- | --- | --- |
| Shared design rules | Visual hierarchy, semantic colors, themes, spacing, typography, interaction states, accessibility, and acceptance criteria | Apply consistently across applications |
| Component integration | DuskMoon components, aggregate package imports, and registration | Apply to applications using the same web component stack |
| Phoenix reference implementation | LiveView, Hologram, HEEx, asset profiles, module paths, and Mix commands | Reuse in Phoenix applications; map to equivalent mechanisms in other stacks |

Framework-specific module names, directory paths, commands, and the development
port are not universal design requirements. Applications on other stacks must
preserve the shared visual and behavioral contract, document their component and
token mapping, and verify it in their own runtime. Copying screenshots alone does
not establish alignment.

"Must" and "must not" define acceptance requirements. "Default" defines the choice
when there is no specific product reason to deviate. Existing pages are
implementation references, not proof that every requirement has been verified.
Address issues within the current task's scope without redesigning unrelated UI.

These rules govern new and changed UI. Keep business validation, persistence,
permissions, and lifecycle transitions in their owning application domain. A visual
alignment task must not silently change those contracts. Record product-specific
decisions and exceptions in the consuming application's alignment record.

All project-authored content must be in English, including UI copy, documentation,
code comments, identifiers, examples, and developer-facing messages.

## 1. Design Direction and Information Hierarchy

- Identify the user's task, primary action, and information density before choosing
  a layout or components.
- Application pages prioritize content and actions. Do not add oversized marketing
  headlines, decorative gradients, glass effects, or unnecessary animation by default.
- Use one `h1` per page, `h2` for sections, and sequential heading levels within cards.
- Emphasize one primary action per independent task area. Use outline or ghost
  styles for supporting actions. A collection of examples may contain independent
  areas, but one action group must not contain competing primary buttons.
- Colors, icons, and animation must not replace necessary text. State must be
  understandable through text.
- Use consistent domain terminology in page titles, navigation, action labels,
  and success messages.

## 2. Components and Asset Entry Points

Prefer `dm_*` components from `PhoenixDuskmoon.Component`, shared layouts, and
existing application patterns. Check the installed dependency's attributes and
slots before using a component. Do not infer APIs from another version or UI library.

Register all browser elements through the aggregate package. Keep this pattern
in `assets/js/app.js`:

```js
import { registerAll } from "@duskmoon-dev/elements";

registerAll();
```

- Application code must not directly import or declare dependencies on individual
  `@duskmoon-dev/el-*` packages.
- Do not return to per-page or per-element registration. Do not repeat registration
  during page mounts or LiveView updates.
- Individual packages used internally by the aggregate package are transitive
  dependencies. Preserve their normal installation and locking; do not manually
  remove their lockfile entries.
- Load CSS through the plugin, themes, and components entry points of
  `@duskmoon-dev/core`. Use `assets/css/app.css` as the source for exact paths.
  Do not introduce a second UI framework or a parallel component library.
- LiveView hooks and custom element registration have separate responsibilities;
  neither replaces the other.
- In the Phoenix reference, hooks handle browser interactions such as opening,
  closing, and focusing a dialog. LiveView owns form state and invokes the owning
  context for validation, authorization, and persistence. Reuse existing hooks.
- Use native HTML for semantic structure and verified cases requiring native form
  behavior, styled with existing Core classes. Do not recreate the appearance and
  interaction of an existing DuskMoon component.
- Place domain-specific compositions in the application component layer. Extract
  patterns that are actually reused, not speculative general-purpose abstractions.

Build assets with DuskMoonBundler and retain the `:gsmlg` profile. Do not bypass
build problems through CDN imports, page-local scripts, dependency patches, or
committed generated assets. Follow the applicable upstream issue policy in
`AGENTS.md` for dependency defects.

## 3. Colors and Themes

Use DuskMoon semantic tokens only. Do not add hardcoded colors in HEEx or CSS,
or fixed palette utilities such as `bg-blue-500`, `text-gray-600`, or `bg-white/80`.
Reference existing `--color-*` variables when custom CSS needs a color.

| Purpose | Background or border | Text |
| --- | --- | --- |
| Page base | `bg-surface` | `text-on-surface` |
| Standard cards and content groups | `bg-surface-container` | `text-on-surface` |
| Navigation and popovers | `bg-surface-container-high` | `text-on-surface` |
| Top-level dialogs | `bg-surface-container-highest` | `text-on-surface` |
| Primary actions and brand emphasis | `bg-primary` | `text-primary-content` |
| Secondary emphasis | `bg-secondary` | `text-secondary-content` |
| Soft emphasis | `bg-primary-container` | `text-on-primary-container` |
| Descriptions, timestamps, supporting information | Inherit the containing surface | `text-on-surface-variant` |
| Content dividers | `border-outline-variant` | Not applicable |
| Interactive boundaries, such as inputs | `border-outline` | Not applicable |

- Pair backgrounds with their corresponding text tokens. Do not retain surface
  text colors on a primary background.
- Use `primary` for main actions, `secondary` for supporting emphasis, and
  `tertiary` sparingly for distinct highlights.
- Use `success`, `warning`, `error`, and `info` for states only, not decoration or
  arbitrary categories. Prefer component variants that provide the complete
  foreground and background pairing.
- Separate content with surface elevation and borders. Avoid heavy shadows by
  default, and do not wrap every paragraph in a card.
- Support both `sunshine` and `moonlight`. Theme changes must preserve information
  hierarchy, layout, and interaction capabilities.
- Show both palettes together in the semantic color reference. Scope each preview
  to its own theme tokens so the app theme preference does not change the comparison.
- Drive the theme through the root `data-theme` attribute. Preserve the existing
  theme switcher and localStorage/cookie synchronization. Pages must render and
  LiveView must connect when storage is unavailable. Do not create independent
  theme state inside individual components.
- Appearance settings present Auto, Light, and Dark as one segmented selection.
  Auto follows the operating system, including changes while the page is open;
  Light resolves to `sunshine`, and Dark resolves to `moonlight`. Persist the
  selected preference rather than replacing Auto with its current resolved theme.
- Keep the home PageHeader's existing theme dropdown. Application Appbars contain
  navigation and application actions; theme preferences belong in Settings →
  Appearance. Both entry points share one preference and synchronize open tabs.

## 4. Page Structure, Density, and Spacing

### Information Architecture and Navigation

- Top-level navigation represents stable product areas; related features belong
  in the matching contextual menu. Define navigation centrally in the shared
  layout, including labels, grouping, and active items.
- A detail or editing page retains the navigation ownership of its parent list.
  Keep route prefixes, breadcrumbs, and active items consistent within an area.
- Configuration pages manage settings; dashboards and monitoring pages show
  runtime data. Give these entry points distinct labels even when they concern
  the same resource.
- Reuse the application's navigation behavior and existing collapse preferences.
  Pages must not duplicate menu headings or maintain independent sidebar state.
- Changes to existing public URLs require compatibility redirects and checks for
  navigation, direct visits, and browser history.

### Sidebar Collapse and Expansion

- Shared desktop sidebars support expanded and collapsed states. Provide a
  visible, keyboard-operable toggle with an action-specific accessible name,
  such as "Collapse navigation" or "Expand navigation", and accurate
  `aria-expanded` and `aria-controls` attributes.
- The default collapsed state is an icon rail. Keep navigation items recognizable
  through icons, accessible names, and tooltips available on hover and keyboard
  focus. Preserve the active item, and keep the expand control reachable.
- Release the unused sidebar width to the content area when collapsed; do not
  leave an empty column or move the appbar. Expanding restores the normal sidebar
  width without covering content or obscuring keyboard focus.
- Own the preference in the shared application shell. Preserve it across page
  navigation and reloads, including navigation between renderers. The saved
  sidebar width must apply from the first paint, before the page runtime starts.
  If browser storage is unavailable, in-page toggling and navigation must still work.
- Collapsing or expanding must preserve the current page, form drafts, selected
  items, and useful scroll positions. It must not submit a form, trigger a
  business action, or reset the theme.
- Keep the collapse control outside the scrolling menu body so it remains
  reachable in long menus. Give the menu and its controls stable identifiers.
- A narrow-screen drawer, when present, is a separate presentation of the same
  navigation. Opening or closing it must not overwrite the desktop collapse
  preference or make essential destinations unreachable.

In the Phoenix reference, use the installed `dm_left_menu` collapsible API and
its `DuskmoonLeftMenu` hook. Supply a stable menu `id`, icon and label metadata,
and a shared `storage_key` when the browser owns persistence. Keep width and
scroll behavior in the shared layout. Other renderers preserve the same visual
and interaction contract through their own runtime, as described in section 8.

### Phoenix Reference Shell

LiveView pages reuse `Layouts.home` for Home and `Layouts.app` for introduction
pages. The hierarchy follows Backplane's separation of public-home and
application pages:

- **Home:** a full-width app page header (`dm_page_header`) combining navigation
  and a centered Hero with a semantic-color gradient, large heading, and entry
  points. Its floating navigation appears when the Hero scrolls out of view.
  Home has no appbar or left menu.
- **Introduction pages:** a full-width primary appbar above a two-column body:
  a secondary left menu (`dm_left_menu`) and the surface content area. The
  appbar links to Overview, Guidelines, Components, and Use Cases. The left
  menu contains the current section's topics and related demonstrations.
- In the application Appbar, place navigation beside the brand on the left,
  as in Backplane. Keep utility actions on the right and omit theme controls.
- On introduction pages, keep the appbar at the top while scrolling and the
  desktop left menu below it. Keep breadcrumbs inside the content area; do not use them in place of
  the appbar. Place the footer below content; Appearance owns theme preferences.
- Identify the current section in the appbar and the current page in the left
  menu. Every left-menu destination has its own path route and renders its
  corresponding content. Do not substitute hash anchors or query selectors for
  page routes. Direct visits, reloads, and browser Back/Forward must restore the
  same content, title, and active menu item.

Hologram uses a separate document layout with the same appbar and left-menu
hierarchy, shared visual tokens, and the persisted theme. Consuming applications
map these two navigation levels to their own product hierarchy.

### Density and Spacing

| Context | Default |
| --- | --- |
| Global navigation and wide workspaces | `max-w-7xl mx-auto` |
| Standard content and form example pages | `max-w-5xl mx-auto` |
| Long-form text and descriptions | `max-w-2xl` or `max-w-3xl` |
| Horizontal page padding | `px-4 sm:px-6` |
| Standard vertical page padding | `py-8` or `py-12` |
| Major section spacing | `space-y-8` or `space-y-10` |
| Standard cards | `p-6`, `gap-6`, `rounded-xl` |
| Dense data regions | `p-4`, `gap-3` or `gap-4` |
| Action groups | `gap-2` or `gap-3`, with wrapping allowed |

- Use consistent spacing and corner radii for comparable regions. Prefer the
  existing spacing scale over arbitrary pixel offsets for alignment.
- Standard pages scroll naturally. Sticky navigation must not obscure headings,
  anchor targets, or keyboard focus.
- Layouts must shrink gracefully. Long names, errors, and action groups must not
  cause page-level horizontal overflow. Give flexible content columns `min-w-0`
  so their children can shrink within the shared shell.
- Stack narrow layouts in reading order. Do not hide primary actions or essential
  data merely to fit the width.
- Wide tables may scroll horizontally within a defined container, not across the
  entire page.
- Unusual widths, density, or spacing must serve the content rather than merely
  making a page look different.

## 5. Typography, Icons, and Copy

- Retain the application's sans-serif baseline. Use monospace for code and
  identifiers. Treat font changes as global design changes; do not introduce
  external fonts or separate font combinations on individual pages.
- Default to `text-3xl font-bold` for page titles, `text-2xl font-semibold` for
  section headings, `text-lg font-semibold` for card titles, `text-base` for body
  text, and `text-sm` for supporting text. Reserve `text-xs` for nonessential
  metadata. The home page's introductory section may use `text-4xl`; do not apply
  that size to every application page.
- Use existing DuskMoon icon support and inherit `currentColor`. Hide decorative
  icons from assistive technology.
- Icon-only buttons must have accessible names. Tooltips must not be their sole
  naming mechanism.
- Write all UI copy in English, including labels, placeholders, validation errors,
  empty states, tooltips, notifications, and accessibility text. Use `lang="en"`
  on application documents. Do not mix languages in project-authored copy.
- Button labels describe the action and object, such as "Save configuration" or
  "Delete project". Avoid an ambiguous "OK" for consequential actions.
- Errors explain what happened and how to recover. Success messages must reflect
  operations that actually completed.
- Clearly identify examples and simulated data. Do not present them as persisted
  results.

## 6. Forms, Actions, and Feedback

| Context | Required behavior |
| --- | --- |
| Forms | Visible labels, necessary format guidance, and field errors; placeholders do not replace labels |
| Validation failure | Preserve input, identify the error and recovery action, and clear stale success messages when input changes |
| Submission | Show loading state, prevent duplicate submission, and preserve button width and context |
| Disabled controls | Use actual disabled behavior or appropriate semantic state, with an understandable reason |
| Empty data | Distinguish "No data yet" from "No matching results" and provide a next step such as creating an item or clearing filters |
| Request failure | Preserve recoverable input and data, offer retry, and do not disguise failure as an empty list |
| Stale data | Identify the last known state and refresh result; keep retry available without blocking unrelated page actions |
| Destructive actions | Identify the affected object and consequences, offer cancellation, and explicitly confirm irreversible actions |
| Progress | Provide an accessible name and accurate range/value; do not show a fabricated percentage for unknown progress |
| Disconnection or expired session | Explain the state and recovery path rather than silently disabling every control |

Prefer existing `dm_form`, `dm_input`, `dm_btn`, `dm_alert`, and `dm_flash_group`
patterns. Use the supported `native_submit` option for native form submission,
and verify Enter submission and error recovery. Place field errors near their
fields and form-level errors near the action area; do not rely solely on transient
toasts. The application owns confirmation state, and cancellation must not execute
the action. Hidden controls and client-side confirmation do not replace server-side
authorization.

### Lists and Table Actions

- Operational list pages present the title and short description, page actions,
  filters when needed, then the list or table. For lists that support creation,
  place the primary Add action in the title area. When an Add/Edit modal is open,
  Save is its primary action.
- Prefer a table for structured configuration, with clear column headings,
  readable status, and a separate Actions column. Use cards when the content
  needs a different reading order rather than to decorate every row.
- Repeated table actions use compact icon buttons with consistent size and shape.
  Page-level Add and form Save/Cancel actions retain visible text labels.
- Every icon action has an accessible name containing the action and object,
  such as "Edit workspace route", and a short tooltip such as "Edit". Tooltips
  must work on hover and keyboard focus. Attach trigger attributes to the actual
  interactive element; a wrapper alone does not establish that behavior.
- Order row actions consistently: edit, enable/disable when applicable, other
  domain actions, then delete. Use destructive styling for delete and confirm
  the affected object and consequences before executing it.
- Enable/disable labels describe the next action. An enabled item offers Disable;
  a disabled item offers Enable. Show the current state separately as text,
  usually in the Status column.
- Give row actions stable, unique identifiers. While an action is pending, show
  progress on the affected row and prevent duplicate requests. Preserve useful
  filter and pagination context after success or failure.

In Phoenix, prefer `dm_table`, `dm_btn`, and existing DuskMoon icon components.
Bind `dm_tooltip` trigger attributes with `:let` and pass them to the actual
`dm_btn`. Pass supported `patch`, `navigate`, or `href` attributes directly to a
navigation button; do not wrap it in another link or nest interactive elements.

### Settings Pages with Section Navigation

- Object settings may use a dedicated page: a title and description, an identity
  header naming the object, and a two-column settings region. The left column
  lists settings sections; the right column contains the active section's form
  or preference controls. Keep a clear return link to the owning area.
- This section navigation belongs to the current object, within the application
  shell. Distinguish it from the global left menu and mark its active destination
  with `aria-current`. Each section has its own path route, supports direct
  visits and browser history, and renders only the selected section.
- Use this pattern for General, integrations, Appearance, and comparable settings.
  Keep long-lived object settings in their page rather than forcing them into an
  Add/Edit modal. Stack the settings region in reading order on narrow layouts.
- Give each section a heading and concise explanation. Forms have visible labels,
  nearby validation, Save and Cancel actions, and one primary action. Preserve
  independent drafts while switching sections; Cancel restores that section's
  last saved values. Identity metadata remains separate from editable fields.
- Immediate preferences such as color mode explain that they apply immediately;
  they do not require a redundant Save button. Keep configuration saves separate
  from authorization, connection tests, and other external operations.

### Add and Edit Modal Forms

- Configuration lists default to Add opening a modal form, with the edit action
  opening the corresponding editing form. Keep a permanent creation form above
  a list only when the workflow has a documented reason for it. Dedicated or
  complex editing workflows may use a separate page.
- The title identifies Add or Edit and names the object. Keep the selected object,
  draft values, validation errors, and submission state explicit.
- Cancel, close, and Escape discard the unsaved draft and clear validation errors
  without writing. The next Add opens a clean form; editing another object must
  not inherit the previous object's values or errors.
- A successful save closes the modal, refreshes the affected list, and shows
  accurate success feedback. Validation or request failure keeps the modal open
  with recoverable input and correctable errors.
- On open, focus a sensible input. Keep keyboard focus within the modal and
  restore it to the trigger on close. Constrain the dialog to the viewport height,
  allow the body to scroll, and keep Save and Cancel reachable on narrow screens.
- Collect only fields required for the task. Select an existing provider or
  credential reference when it already owns connection details; do not duplicate
  endpoint and secret fields across capability forms.

In Phoenix, use `dm_modal` with native dialog behavior and the installed
components/hooks to coordinate browser state. LiveView owns whether the form
exists and which object it edits. DOM patches must preserve an open, valid draft.
Forms explicitly use `phx-submit`; Save uses the supported submit behavior, and
non-submit buttons set `type="button"`.

### Configuration Defaults and State Changes

- Define creation defaults in the consuming application's domain contract, and
  keep schema/context and database defaults consistent. When a product requires
  enabled-by-default configuration, enforce it on the server; do not rely only
  on a prefilled control or trust an extra submitted enabled field.
- Keep enable/disable transitions separate from ordinary editing. After creation,
  use the list's explicit state action; editing other fields preserves the current
  enabled state. Ordinary Edit forms do not include an enable switch.
- Creation forms expose only permitted inputs. A lifecycle default owned by the
  domain must not be represented as a client-controlled hidden state field.
- Changing a creation default affects future objects. Preserve existing objects'
  state unless an explicit migration is part of the authorized task.
- Configured enablement and actual availability are separate states. An enabled
  item with an unavailable dependency must show the specific reason. Connection,
  authorization, and job execution results come from the actual operation.

### Feedback and Data Boundaries

- Keep feedback near the task: field and form errors inside the form, row progress
  beside the affected item, and completed action results in the shared flash/alert.
  Clear stale success feedback when the input or result is no longer current.
- Opening a configuration page or form, and ordinary saves, must not implicitly
  run paid API probes. Connection tests, external refreshes, and similar operations
  need explicit, separately named actions.
- Configuration lists show credential names or references. Do not echo plaintext
  secrets in lists, logs, audit entries, or error messages. Dedicated credential
  issuance and reveal flows follow their product's explicit access rules.

## 7. Accessibility and Motion

- Every action must be keyboard-operable. Preserve visible `focus-visible` styling;
  never simply remove the outline.
- Use links for navigation and buttons for actions. Do not simulate buttons with
  clickable `div` elements or nest interactive controls.
- Dialogs need a title, sensible initial focus, keyboard dismissal, and focus
  restoration on close. Modal interfaces must contain focus appropriately.
- Tooltips, menus, confirmations, and dialogs must remain usable inside or above
  scrollable regions. Prevent table overflow containers from clipping their
  controls, text, or focus indicators.
- Use suitable `role="status"` or `aria-live` regions for dynamic updates and
  appropriate alerts for important errors. Avoid announcing entire lists.
- Target at least 4.5:1 contrast for body text and 3:1 for essential control
  boundaries and focus indicators. Check both themes.
- Primary interaction targets default to at least 44 by 44 CSS pixels. Exceptions
  in dense data views must preserve keyboard and pointer usability.
- Motion explains state changes and defaults to approximately 150-200ms. Animate
  only the necessary properties; do not apply global `transition: all`.
- Respect `prefers-reduced-motion` by removing nonessential movement and animation.
  State must remain understandable without motion.
- Noninteractive cards must not use pointer cursors, button-like hover effects,
  or movement that falsely implies clickability.

## 8. Renderer and State Boundaries

- The standalone React preview runs in an isolated same-origin document and follows
  the parent theme. A React form embedded in LiveView owns the children of its
  ignored mount node. The hook mounts and unmounts React, and submits through an
  explicit LiveView event. Keep the React stylesheet inside the preview document
  or shadow root so it does not override the host styles.
- LiveView owns server-connected interactions; Hologram owns browser-side
  interactions within its pages. They use separate documents and must not both
  control the same DOM subtree.
- Hologram must not load `assets/js/app.js`, which starts LiveSocket. If a Hologram
  page needs Web Components, use a separate browser entry point that calls
  `registerAll()` from the same aggregate package, and verify loading and
  registration independently.
- Use `.link` with `navigate` or `patch` and verified routes for LiveView navigation.
  Use full document navigation when crossing renderer boundaries.
- Sharing a theme does not mean sharing every client runtime. Preserve the theme
  across navigation, reloads, and browser history.
- Saving, reloading, reconnecting, and session expiration must reflect the actual
  data lifecycle. Do not describe page assigns, Session Process state, or client
  state as database persistence.
- When changing Web Component integrations, verify focus, events, and form
  behavior in the actual Shadow DOM. Server-rendered tags alone do not prove
  that a component works.

## 9. Acceptance and Change Rules

For UI changes, check the applicable scenarios:

- [ ] Shared layouts, supported component APIs, and semantic tokens are used,
  without individual component package imports or per-element registration.
- [ ] Heading hierarchy, primary actions, density, spacing, and copy follow this
  document; all project-authored text is in English.
- [ ] Navigation is defined centrally; list, detail, and editing pages retain the
  correct product area, contextual menu, active item, and route compatibility.
- [ ] Every left-menu destination has a distinct path, renders its own content,
  and restores its title and active item on direct visits, reloads, and history.
- [ ] Sidebar collapse and expansion work with the keyboard, preserve state
  across navigation and reloads, keep rail destinations and the expand control
  accessible, and release the collapsed width to the content area.
- [ ] Table actions have consistent order, accessible object-specific names,
  working tooltips, and accurate current-state and next-action labels.
- [ ] Text, inputs, states, and focus remain legible in `sunshine` and `moonlight`.
- [ ] Appearance supports Auto, Light, and Dark; Auto follows system changes,
  explicit modes remain fixed, and both theme entry points share the preference.
- [ ] Object settings preserve section ownership, bookmarkable navigation,
  independent drafts, and accurate save/cancel behavior.
- [ ] Applicable default, loading, empty, error, success, disabled, and disconnected
  states have real behavior.
- [ ] Forms support validation, cancellation, and retry without duplicate
  submission or loss of recoverable input.
- [ ] Add/Edit drafts and errors are isolated per object; Cancel, close, and Escape
  write nothing, success closes the modal, and failure preserves the draft.
- [ ] Creation defaults match the product's domain contract, ordinary editing
  preserves enablement, and availability reflects actual dependency state.
- [ ] Keyboard operation, accessible names, and required focus restoration work.
- [ ] Components are registered in a real browser; the document, CSS, and JS load
  successfully, and relevant LiveView interactions work.
- [ ] No new application console errors occur. Distinguish valid cache responses
  from loading failures without hiding failed assertions.
- [ ] Report the themes, pages, and viewports actually verified. Do not claim mobile
  or responsive validation that was not performed.

For template, runtime, or asset code changes, run `mix precommit`,
`mix assets.deploy`, `git diff --check`, and the relevant frontend checks. Start
development with `mix dev`. The current configuration defaults to port 4444,
with a `PORT` override available. Browser checks must use the actual server address:

```sh
npm test
PLAYWRIGHT_BASE_URL=http://localhost:4444 npm run test:browser
```

For documentation-only changes, check content, relative links, and
`git diff --check`. These checks do not establish UI or build acceptance. Changes
to global colors, component sources, registration, layout, or interaction rules
must update this document and explain their impact. Do not silently turn a
single-page exception into a global convention.

For list and modal changes, regress create, edit, cancellation, validation, state
changes, and object isolation at the owning domain and UI layers. Open, focus,
and close tooltips and dialogs in a real browser; DOM presence alone does not
verify focus restoration, Escape behavior, or clipping. When responsive validation
is in the task's scope, include a narrow viewport around 390 CSS pixels and verify
table scrolling and reachable form actions alongside the desktop layout.

## 10. Downstream Alignment and Specification Distribution

`DESIGN.md` is the specification to distribute to consuming applications. Runnable
examples provide implementation guidance and evidence for specific scenarios;
they do not silently override written rules. Resolve contradictions explicitly
by updating the specification or the implementation.

### Adoption Record

Each consuming application must keep an English alignment record containing:

| Field | Required content |
| --- | --- |
| Source | This repository and the adopted specification's commit SHA or release tag |
| Component stack | The application's UI packages and resolved versions |
| Mapping | Shared token roles, components, themes, and states mapped to the application's implementation |
| Scope | Pages and workflows covered by the alignment work |
| Evidence | Checks performed, including themes, viewports, interactions, and accessibility behavior |
| Gaps and exceptions | Unverified behavior, known deviations, reasons, and planned resolution where applicable |

Compare the adopted revision with the intended new revision before updating an
application. Review changes to tokens, component APIs, layouts, interaction
behavior, and acceptance criteria together; do not assume a dependency version
bump alone establishes design alignment.

Adopting the list and modal conventions requires workflow and focus verification
for the affected pages. Keep product-specific creation defaults explicit, and
record older pages awaiting alignment as gaps rather than claiming site-wide
compliance from a documentation update.

### Distribution Rules

- Distribute the shared rules, relevant integration requirements, and acceptance
  criteria together. A screenshot collection or component inventory is not a
  complete specification.
- Identify the source revision and applicable component versions in each exported
  copy. A moving branch name alone is insufficient to reproduce an adopted baseline.
- Keep copied documents traceable to this source. Record application-specific
  additions separately so they are not mistaken for shared requirements.
- Preserve usable implementation references when exporting outside this checkout:
  include the referenced files or link to their immutable source revision instead
  of leaving broken relative links or local machine paths.
- Identify verification gaps explicitly. Publishing a specification does not mean
  every reference page or consuming application has passed its acceptance checks.
- Shared design changes must explain their downstream impact and any migration
  steps. Keep the reference examples and written specification consistent within
  the scope of the change.

An application is aligned only for the scope it has actually verified against an
identified specification revision. Track partial adoption and exceptions openly;
do not claim application-wide alignment from a single example page.

### Working Export

The Guidelines page serves this exact file at `/guidelines/DESIGN.md`. Its
`X-Design-Spec-SHA256` response header identifies the content even before a commit
or release exists. This working export is not a published release. At adoption,
record the content hash and the source commit or release when available; preserve
the matching checkout for the implementation paths below.

## 11. Implementation References

These paths refer to the matching source checkout, not separately published pages.

- Shared shell: `lib/gsmlg_web/components/layouts.ex` and `lib/gsmlg_web/components/layouts/root.html.heex`.
- Styles and browser setup: `assets/css/app.css`, `assets/js/app.js`, and `assets/js/theme.js`.
- Component examples: `lib/gsmlg_web/live/components_live.ex`,
  `assets/js/react_preview.js`, and `assets/js/react_form.js`.
- Workflow examples: `lib/gsmlg_web/live/use_cases_live.ex` and `lib/gsmlg_web/live/session_live.ex`.
- Settings page composition: `lib/gsmlg_web/live/settings_live.ex`.
- Browser-local renderer: `lib/gsmlg_web/hologram/layout.ex`.
- Integration and checks: `lib/gsmlg_web.ex`, `assets/browser/template.spec.mjs`, and `AGENTS.md`.
- Pinned upstream sources and adaptation notes: `docs/design-reference-sources.md`.

The navigation, list-action, modal-lifecycle, and feedback conventions were
adapted from the [Backplane UI Implementation Guidelines](https://github.com/gsmlg-opt/backplane/blob/08fa68bc9185e16df652b7daab699cd5fa23816c/DESIGN.md),
reviewed on 2026-11-18. Apply them through this specification's shared rules and
the consuming application's domain contract; component registration in this
template continues to use the aggregate `registerAll()` pattern in section 2.
