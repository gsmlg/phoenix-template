defmodule GsmlgWeb.SettingsLive do
  use GsmlgWeb, :live_view

  @general %{
    "name" => "Design workspace",
    "description" => "A shared space for interface guidance."
  }
  @github %{"repository" => "duskmoon-dev/design"}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Workspace settings",
       section: "general",
       general: @general,
       saved_general: @general,
       general_errors: %{},
       github: @github,
       saved_github: @github,
       github_error: nil,
       feedback: nil
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    if Map.has_key?(params, "section") do
      {:noreply, push_patch(socket, to: section_path(params["section"]), replace: true)}
    else
      section = Atom.to_string(socket.assigns.live_action)

      title =
        if section == "general",
          do: "Workspace settings",
          else: section_title(section) <> " · Workspace settings"

      {:noreply, assign(socket, section: section, page_title: title, feedback: nil)}
    end
  end

  @impl true
  def handle_event("validate_general", %{"profile" => fields}, socket) do
    profile = Map.merge(socket.assigns.general, Map.take(fields, ~w(name description)))

    {:noreply,
     assign(socket, general: profile, general_errors: general_errors(profile), feedback: nil)}
  end

  def handle_event("save_general", %{"profile" => fields}, socket) do
    draft = Map.merge(socket.assigns.general, Map.take(fields, ~w(name description)))
    errors = general_errors(draft)

    if errors == %{} do
      saved = Map.new(draft, fn {key, value} -> {key, String.trim(value)} end)

      {:noreply,
       assign(socket,
         general: saved,
         saved_general: saved,
         general_errors: %{},
         feedback: "Workspace profile saved for this preview."
       )}
    else
      {:noreply, assign(socket, general: draft, general_errors: errors, feedback: nil)}
    end
  end

  def handle_event("cancel_general", _params, socket) do
    {:noreply,
     assign(socket, general: socket.assigns.saved_general, general_errors: %{}, feedback: nil)}
  end

  def handle_event("validate_github", %{"integration" => fields}, socket) do
    github = Map.merge(socket.assigns.github, Map.take(fields, ~w(repository)))
    {:noreply, assign(socket, github: github, github_error: github_error(github), feedback: nil)}
  end

  def handle_event("save_github", %{"integration" => fields}, socket) do
    draft = Map.merge(socket.assigns.github, Map.take(fields, ~w(repository)))
    error = github_error(draft)

    if is_nil(error) do
      saved = %{"repository" => String.trim(draft["repository"])}

      {:noreply,
       assign(socket,
         github: saved,
         saved_github: saved,
         github_error: nil,
         feedback: "Repository saved for this preview. No GitHub connection was made."
       )}
    else
      {:noreply, assign(socket, github: draft, github_error: error, feedback: nil)}
    end
  end

  def handle_event("cancel_github", _params, socket) do
    {:noreply,
     assign(socket, github: socket.assigns.saved_github, github_error: nil, feedback: nil)}
  end

  def handle_event("theme_changed", _params, socket), do: {:noreply, socket}

  defp general_errors(profile) do
    %{}
    |> then(fn errors ->
      if String.length(String.trim(profile["name"])) in 2..60,
        do: errors,
        else: Map.put(errors, :name, "Use between 2 and 60 characters.")
    end)
    |> then(fn errors ->
      if String.length(profile["description"]) <= 300,
        do: errors,
        else: Map.put(errors, :description, "Use no more than 300 characters.")
    end)
  end

  defp github_error(%{"repository" => repository}) do
    if String.length(repository) <= 100 &&
         Regex.match?(~r/^[A-Za-z0-9][A-Za-z0-9_.-]*\/[A-Za-z0-9_.-]+$/, String.trim(repository)),
       do: nil,
       else: "Use owner/repository, for example duskmoon-dev/design."
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active="use-cases" page="settings-page">
      <div class="design-page">
        <header>
          <p class="design-eyebrow">Use case / Settings page</p>
          <h1 class="design-title">Workspace settings</h1>
          <p class="design-lead">
            Object details above, section navigation on the left, and one focused form on the right.
          </p>
          <p class="mt-3 text-sm text-on-surface-variant">
            This is a synthetic workspace. Saves stay in this page; reloading restores the sample data.
          </p>
        </header>

        <section
          id="workspace-settings-layout"
          class="design-settings-frame"
          aria-label="Workspace administration"
        >
          <header class="design-settings-identity">
            <div>
              <h2 id="settings-workspace-name" class="text-2xl font-semibold">
                {@saved_general["name"]}
              </h2>
              <p class="mt-2 text-sm text-on-surface-variant">@design-workspace</p>
            </div>
            <.link navigate={~p"/use-cases"} class="design-text-link">Back to use cases</.link>
          </header>

          <div class="design-settings-body">
            <nav class="design-settings-nav" aria-label="Workspace settings sections">
              <h2>Workspace settings</h2>
              <.link patch={~p"/use-cases/settings"} aria-current={@section == "general" && "page"}>
                General
              </.link>
              <.link
                patch={~p"/use-cases/settings/github"}
                aria-current={@section == "github" && "page"}
              >
                GitHub integration
              </.link>
              <.link
                patch={~p"/use-cases/settings/appearance"}
                aria-current={@section == "appearance" && "page"}
              >
                Appearance
              </.link>
            </nav>

            <section class="design-settings-panel" aria-labelledby="settings-section-title">
              <p class="design-eyebrow">Workspace administration</p>
              <h2 id="settings-section-title">{section_title(@section)}</h2>

              <div :if={@section == "general"}>
                <p class="mt-3 text-sm text-on-surface-variant">
                  Manage this workspace's public profile.
                </p>
                <.dm_form
                  id="workspace-general-form"
                  for={%{}}
                  as={:profile}
                  phx-change="validate_general"
                  phx-submit="save_general"
                  novalidate
                >
                  <div class="space-y-5">
                    <.dm_input
                      id="settings-display-name"
                      name="profile[name]"
                      label="Display name"
                      value={@general["name"]}
                      errors={List.wrap(@general_errors[:name])}
                      helper="Use 2–60 characters."
                      maxlength="60"
                    />
                    <.dm_textarea
                      id="settings-description"
                      name="profile[description]"
                      label="Description"
                      value={@general["description"]}
                      errors={List.wrap(@general_errors[:description])}
                      helper="Optional. Use no more than 300 characters."
                      rows={4}
                      maxlength={300}
                    />
                    <div class="space-y-2 text-sm text-on-surface-variant">
                      <p>Workspace slug: <code class="text-on-surface">@design-workspace</code></p>
                      <p>
                        The slug identifies the sample workspace and stays unchanged when its name is edited.
                      </p>
                    </div>
                  </div>
                  <:actions>
                    <.dm_btn
                      id="save-workspace-profile"
                      native_submit
                      variant="primary"
                      phx-disable-with="Saving…"
                    >
                      Save changes
                    </.dm_btn>
                    <.dm_btn
                      id="cancel-workspace-profile"
                      type="button"
                      variant="ghost"
                      phx-click="cancel_general"
                    >
                      Cancel changes
                    </.dm_btn>
                  </:actions>
                </.dm_form>
              </div>

              <div :if={@section == "github"}>
                <p class="mt-3 text-sm text-on-surface-variant">
                  Choose the repository shown by this workspace's integration.
                </p>
                <div class="mt-5">
                  <.dm_alert variant="info">
                    This preview does not authorize an account or make GitHub requests.
                  </.dm_alert>
                </div>
                <.dm_form
                  id="workspace-github-form"
                  for={%{}}
                  as={:integration}
                  phx-change="validate_github"
                  phx-submit="save_github"
                  novalidate
                >
                  <.dm_input
                    id="settings-repository"
                    name="integration[repository]"
                    label="Repository"
                    value={@github["repository"]}
                    errors={List.wrap(@github_error)}
                    helper="Use owner/repository, for example duskmoon-dev/design."
                    maxlength="100"
                  />
                  <:actions>
                    <.dm_btn
                      id="save-workspace-integration"
                      native_submit
                      variant="primary"
                      phx-disable-with="Saving…"
                    >
                      Save integration
                    </.dm_btn>
                    <.dm_btn
                      id="cancel-workspace-integration"
                      type="button"
                      variant="ghost"
                      phx-click="cancel_github"
                    >
                      Cancel changes
                    </.dm_btn>
                  </:actions>
                </.dm_form>
              </div>

              <div :if={@section == "appearance"}>
                <p class="mt-3 text-sm text-on-surface-variant">
                  Choose the system theme preference: automatic, light, or dark. Changes apply immediately and are remembered in this browser.
                </p>
                <.dm_toggle_group
                  id="appearance-preference"
                  class="mt-6 w-full rounded-full bg-surface"
                  variant="chip"
                  label="Color mode"
                  exclusive
                  data-appearance-control
                  phx-hook="AppearancePreference"
                  phx-update="ignore"
                >
                  <:item value="default" icon="monitor" class="flex-none rounded-full px-6">
                    Auto
                  </:item>
                  <:item
                    value="sunshine"
                    icon="white-balance-sunny"
                    class="flex-none rounded-full px-6"
                  >
                    Light
                  </:item>
                  <:item
                    value="moonlight"
                    icon="moon-waning-crescent"
                    class="flex-none rounded-full px-6"
                  >
                    Dark
                  </:item>
                </.dm_toggle_group>
              </div>

              <div :if={@feedback} id="settings-feedback" class="mt-6" role="status">
                <.dm_alert variant="success">{@feedback}</.dm_alert>
              </div>
            </section>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  defp section_title("general"), do: "General"
  defp section_title("github"), do: "GitHub integration"
  defp section_title("appearance"), do: "Appearance"

  defp section_path("github"), do: ~p"/use-cases/settings/github"
  defp section_path("appearance"), do: ~p"/use-cases/settings/appearance"
  defp section_path(_), do: ~p"/use-cases/settings"
end
