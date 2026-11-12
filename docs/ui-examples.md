# Phoenix DuskMoon recipes

Open `/ui` from the **UI examples** link in the application header. The examples
use PhoenixDuskmoon components imported through `GsmlgWeb`, not a separate UI kit.

| Scenario | Components | State and behavior |
| --- | --- | --- |
| Actions/navigation | `dm_btn` | Primary/outline, disabled/loading previews, LiveView and full-page navigation |
| Profile form | `dm_form`, `dm_input`, `dm_btn native_submit`, `dm_alert` | Validate on change and submit, show field errors, clear stale success |
| Searchable cards | `dm_card`, `dm_badge`, `dm_input` | Filter a fixed collection, empty state, recover by clearing search |
| Confirmation | `dm_btn` | Inline, explicitly labelled confirmation; cancel, confirm and restore; no real deletion |
| Progress | `dm_progress`, `dm_badge`, `dm_btn` | Simulated 25% steps, bounded at 100%, reset |
| Theme | `dm_theme_switcher` in the shared layout | Sunshine/moonlight with the existing persistence behavior |

## Copy a pattern

Start with `lib/gsmlg_web/live/ui_live.ex`. Every section names its component and
states whether it is simulated. Demo form values, filtering and confirmation are
local LiveView assigns, reset on reload, and never written to Ecto. The home page
is the separate Session Process persistence example; `/hologram-demo` shows
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

`assets/js/app.js` registers the button and alert custom elements as well as
Phoenix DuskMoon's LiveView hooks. Native form inputs, cards, badges and progress
use the Core stylesheet. Adding a hook alone does not register a custom element.

The component attributes and slots used here were checked against upstream source
at `b115f533c24587c0b6ea8ca1ec3598d9e782863a`:
https://github.com/duskmoon-dev/phoenix-duskmoon-ui/tree/b115f533c24587c0b6ea8ca1ec3598d9e782863a/apps/phoenix_duskmoon/lib/phoenix_duskmoon/component

This is a starter set, not a claim of exhaustive component coverage. Dialog,
upload, data-grid, rich editor and async backend examples require their own
application contracts and integration tests.

## Verification

`test/gsmlg_web/live/ui_live_test.exs` covers invalid/valid/resubmitted forms,
search recovery, cancel-confirm-restore and bounded progress. The Playwright
recipe exercises custom elements in the browser, reload state and runtime errors.
These integration/browser tests are authored but not yet run because the existing
Mix dependency lock cannot resolve in this environment. See `validation.md`.
