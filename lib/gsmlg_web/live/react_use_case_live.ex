defmodule GsmlgWeb.ReactUseCaseLive do
  use GsmlgWeb, :live_view

  @name_min 3
  @name_max 60
  @visibility_options ["Private", "Team"]
  @schema %{
    "$schema" => "https://json-schema.org/draft/2020-12/schema",
    "type" => "object",
    "properties" => %{
      "name" => %{
        "type" => "string",
        "title" => "Project name",
        "minLength" => @name_min,
        "maxLength" => @name_max
      },
      "visibility" => %{
        "type" => "string",
        "title" => "Visibility",
        "enum" => @visibility_options,
        "default" => "Private"
      },
      "email_updates" => %{
        "type" => "boolean",
        "title" => "Email updates",
        "default" => false
      }
    },
    "required" => ["name", "visibility", "email_updates"],
    "additionalProperties" => false
  }

  @impl true
  def mount(_params, _session, socket) do
    {page, title, description, hook, props} =
      case socket.assigns.live_action do
        :chat ->
          {"react-chat", "React Chat",
           "Send a message to a demo assistant. LiveView returns a scripted reply.",
           "MountReactChat", %{}}

        :form ->
          {"react-form", "React Form",
           "Fill in a project form generated from JSON Schema and see what LiveView receives.",
           "MountReactSchemaForm", %{schema: @schema}}
      end

    {:ok,
     assign(socket,
       page: page,
       page_title: title,
       description: description,
       hook: hook,
       react_props: Jason.encode!(props),
       schema_source: Jason.encode!(@schema, pretty: true),
       submission: nil
     )}
  end

  @impl true
  def handle_event(
        "react-chat-send",
        %{"message" => value},
        %{assigns: %{live_action: :chat}} = socket
      )
      when is_binary(value) do
    message = String.trim(value)

    if String.length(message) in 1..500 do
      {:reply,
       %{
         message: message,
         reply:
           "For a release review, open the preview in both themes and check keyboard navigation."
       }, socket}
    else
      {:reply, %{error: "Enter a message between 1 and 500 characters."}, socket}
    end
  end

  def handle_event("react-chat-send", _params, socket) do
    {:reply, %{error: "Enter a message and try again."}, socket}
  end

  def handle_event(
        "react-schema-submit",
        %{"name" => name, "visibility" => visibility, "email_updates" => updates} = values,
        %{assigns: %{live_action: :form}} = socket
      )
      when map_size(values) == 3 and is_binary(name) and is_boolean(updates) do
    name = String.trim(name)

    cond do
      String.length(name) not in @name_min..@name_max ->
        {:reply, %{errors: %{"/name" => "Use between #{@name_min} and #{@name_max} characters."}},
         socket}

      visibility not in @visibility_options ->
        {:reply, %{errors: %{"/visibility" => "Choose an available visibility."}}, socket}

      true ->
        submission = Jason.encode!(%{values | "name" => name}, pretty: true)
        {:reply, %{ok: true}, assign(socket, submission: submission)}
    end
  end

  def handle_event("react-schema-submit", _params, socket) do
    {:reply, %{errors: %{"" => "Check the project fields and submit again."}}, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active="use-cases" page={@page}>
      <div class="design-page">
        <header class="max-w-3xl">
          <p class="design-eyebrow">Reference / Use cases</p>
          <h1 class="design-title">{@page_title}</h1>
          <p class="design-lead">{@description}</p>
        </header>
        <section id={@page} aria-label={@page_title <> " demo"} class="design-section max-w-4xl">
          <div class="design-preview">
            <div class="design-preview-body">
              <div
                id={@page <> "-mount"}
                phx-hook={@hook}
                phx-update="ignore"
                data-react-props={@react_props}
                data-react-stylesheet={
                  DuskmoonBundler.static_path(GsmlgWeb.Endpoint, "/assets/css/react_preview.css",
                    profile: :gsmlg
                  )
                }
              >
                <div role="status">
                  <span class="sr-only">Loading {@page_title}…</span>
                  <div aria-hidden="true" data-react-skeleton class="grid max-w-xl gap-4">
                    <div class="skeleton h-14 w-3/4"></div>
                    <div class="skeleton skeleton-input"></div>
                    <div class="skeleton skeleton-button"></div>
                  </div>
                </div>
              </div>
              <div :if={@live_action == :form} id="react-schema-result" role="status">
                <div :if={@submission} class="mt-6 space-y-2">
                  <p class="font-semibold">Received by LiveView</p>
                  <pre class="design-code rounded-lg"><code>{@submission}</code></pre>
                </div>
              </div>
            </div>
            <details :if={@live_action == :form} class="border-t border-outline-variant">
              <summary class="cursor-pointer px-6 py-4 text-sm font-medium">View JSON Schema</summary>
              <pre class="design-code"><code>{@schema_source}</code></pre>
            </details>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
