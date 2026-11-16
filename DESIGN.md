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
- Drive the theme through the root `data-theme` attribute. Preserve the existing
  theme switcher and localStorage/cookie synchronization. Pages must render and
  LiveView must connect when storage is unavailable. Do not create independent
  theme state inside individual components.

## 4. Page Structure, Density, and Spacing

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
- On introduction pages, keep the appbar at the top while scrolling and the
  desktop left menu below it. Keep breadcrumbs inside the content area; do not use them in place of
  the appbar. Place the theme control in the appbar and the footer below content.
- Identify the current section in the appbar and the current page in the left
  menu. Topic links scroll to headings; they do not imply automatic scroll tracking.

Hologram uses a separate document layout with the same appbar and left-menu
hierarchy, shared visual tokens, and the persisted theme. Consuming applications
map these two navigation levels to their own product hierarchy.

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
  cause page-level horizontal overflow.
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

## 7. Accessibility and Motion

- Every action must be keyboard-operable. Preserve visible `focus-visible` styling;
  never simply remove the outline.
- Use links for navigation and buttons for actions. Do not simulate buttons with
  clickable `div` elements or nest interactive controls.
- Dialogs need a title, sensible initial focus, keyboard dismissal, and focus
  restoration on close. Modal interfaces must contain focus appropriately.
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

- The React example runs in an isolated same-origin document with its own bundle.
  Import React components from `@duskmoon-dev/components`; its theme follows the
  parent document. Do not mount React into LiveView-managed DOM.
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
- [ ] Text, inputs, states, and focus remain legible in `sunshine` and `moonlight`.
- [ ] Applicable default, loading, empty, error, success, disabled, and disconnected
  states have real behavior.
- [ ] Forms support validation, cancellation, and retry without duplicate
  submission or loss of recoverable input.
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
- Component examples: `lib/gsmlg_web/live/components_live.ex` and `assets/js/react_preview.js`.
- Workflow examples: `lib/gsmlg_web/live/use_cases_live.ex` and `lib/gsmlg_web/live/session_live.ex`.
- Browser-local renderer: `lib/gsmlg_web/hologram/layout.ex`.
- Integration and checks: `lib/gsmlg_web.ex`, `assets/browser/template.spec.mjs`, and `AGENTS.md`.
- Pinned upstream sources and adaptation notes: `docs/design-reference-sources.md`.
