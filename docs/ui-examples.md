# Duskmoon Phoenix recipes

Open `/use-cases` from **Use Cases** in the reference navigation. `/ui` remains a compatibility redirect. The examples
use `DuskmoonPhoenix.Component` through `GsmlgWeb`.

| Scenario | Components | State and behavior |
| --- | --- | --- |
| Actions/navigation | `dm_btn` | Primary/outline, disabled/loading previews, LiveView and full-page navigation |
| Profile form | `dm_form`, `dm_input`, `dm_btn native_submit`, `dm_alert` | Validate on change and submit, show field errors, clear stale success |
| Searchable records | `dm_card`, `dm_badge`, `dm_input` | Filter a fixed collection by query and status, inspect details, and clear filters to recover |
| Confirmation | `dm_btn` | Inline, explicitly labelled confirmation; cancel, confirm and restore; no real deletion |
| Progress | `dm_progress`, `dm_badge`, `dm_btn` | Simulated 25% steps, bounded at 100%, reset |
| Theme | `dm_theme_switcher` in the shared layout | Sunshine/moonlight with the existing persistence behavior |

## Copy a pattern

Start with `lib/gsmlg_web/live/use_cases_live.ex`. Every section names its component and
states whether it is simulated. Demo form values, filtering and confirmation are
local LiveView assigns, reset on reload, and never written to Ecto. `/use-cases/session`
is the separate Session Process example; `/hologram-demo` shows
browser-side Elixir. Do not infer that profile data should live in Session Process.

A validated native-submit form follows this structure:

```heex
<.dm_form id="profile-form" for={%{}} as={:profile}
  phx-change="validate" phx-submit="save" novalidate>
  <.dm_input name="profile[name]" id="profile-name" label="Display name"
    value={@name} errors={if @error, do: [@error], else: []} />
  <:actions><.dm_btn native_submit>Save</.dm_btn></:actions>
</.dm_form>
```

For a real application, replace the small demo validator with a context changeset,
check authorization in event handlers, and persist only after successful validation.
The confirmation example guards the transition on the server; hiding a button is
not authorization. Keep cancellation and repeated actions covered by tests.

## Runtime wiring and API evidence

`assets/js/app.js` registers all elements through `@duskmoon-dev/elements` and
loads native LiveView hooks from `duskmoon_phoenix/hooks`. Native form inputs,
cards, badges, and progress use the Core styles included in `duskmoon_phoenix/css`.

See the [Duskmoon Phoenix component source](https://github.com/duskmoon-dev/duskmoon-web/tree/v2.0.0-rc.3/phoenix/apps/duskmoon_phoenix/lib/duskmoon_phoenix/component)
for attributes and slots. The [consumer skill](https://github.com/duskmoon-dev/duskmoon-web/tree/v2.0.0-rc.3/skills/duskmoon-phoenix)
covers setup and optional integrations.

This is a starter set, not a claim of exhaustive component coverage. Dialog,
upload, data-grid, rich editor and async backend examples require their own
application contracts and integration tests.

## Verification

`test/gsmlg_web/live/use_cases_live_test.exs` covers invalid/valid/resubmitted forms,
search recovery, cancel-confirm-restore and bounded progress. The Playwright
recipe exercises custom elements in the browser, reload state and runtime errors.
The current validation results are recorded in [validation status](validation.md).
