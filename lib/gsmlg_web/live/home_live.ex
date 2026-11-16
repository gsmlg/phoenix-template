defmodule GsmlgWeb.HomeLive do
  use GsmlgWeb, :live_view
  alias Gsmlg.DesignCatalog

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Overview", repositories: DesignCatalog.repositories())}
  end

  def handle_event("theme_changed", _params, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <Layouts.home flash={@flash}>
      <:hero>
        <section class="design-home-hero" aria-labelledby="overview-title">
          <span class="design-home-emblem" aria-hidden="true">d.</span>
          <p class="design-home-eyebrow">DuskMoon · A shared foundation for our applications</p>
          <h1 id="overview-title">One design language.<br />Every interface.</h1>
          <p class="design-home-lead">
            Explore working components, adopt shared guidelines, and bring consistent patterns into your next application.
          </p>
          <div class="design-home-actions">
            <.link navigate={~p"/components"} class="btn btn-primary">Explore components →</.link>
            <.link navigate={~p"/guidelines"} class="design-home-source">Read the guidelines</.link>
          </div>
          <nav class="design-home-layers" aria-label="DuskMoon repository layers">
            <a :for={repo <- @repositories} href={DesignCatalog.repository_url(repo)}>
              {repo.name} <span aria-hidden="true">↗</span>
            </a>
          </nav>
        </section>
      </:hero>
      <div class="design-page design-home-content">
        <section class="design-section" aria-labelledby="start-title">
          <div class="design-section-heading">
            <h2 id="start-title">Find your starting point</h2><span class="design-small-label">FROM PRINCIPLE TO PRACTICE</span>
          </div>
          <div class="design-grid">
            <.link navigate={~p"/guidelines"} class="design-entry-card">
              <span class="design-small-label">01 / ALIGN</span><h3>
                Start with the foundations <span aria-hidden="true">↗</span>
              </h3>
              <p>
                Colors, type, spacing, interaction, and accessibility. A specification your application can adopt.
              </p>
            </.link>
            <.link navigate={~p"/components"} class="design-entry-card">
              <span class="design-small-label">02 / COMPOSE</span><h3>
                Meet the building blocks <span aria-hidden="true">↗</span>
              </h3>
              <p>
                Working previews with usage examples. Compare Core, custom elements, React, and Phoenix.
              </p>
            </.link>
            <.link navigate={~p"/use-cases"} class="design-entry-card">
              <span class="design-small-label">03 / APPLY</span><h3>
                See patterns in context <span aria-hidden="true">↗</span>
              </h3>
              <p>
                Settings, filtering, confirmation, and status. Adapted from real applications using synthetic data.
              </p>
            </.link>
          </div>
        </section>

        <section id="repositories" class="design-section" aria-labelledby="repositories-title">
          <div class="design-section-heading">
            <div>
              <p class="design-eyebrow">THE ECOSYSTEM</p><h2 id="repositories-title">
                Five repositories. Clear responsibilities.
              </h2>
            </div><a href="https://github.com/duskmoon-dev" class="design-text-link">View organization ↗</a>
          </div>
          <div class="design-repo-list">
            <article :for={repo <- @repositories} id={"repository-#{repo.id}"} class="design-repo-row">
              <span class="design-stack-index">{repo.number}</span>
              <div>
                <h3>
                  <a href={DesignCatalog.repository_url(repo)}>duskmoon-dev/{repo.repository}</a>
                </h3><code class="design-package">{repo.package}</code>
              </div>
              <p>{repo.description}</p>
              <a href={repo.demo} class="design-text-link">Explore
              <span class="sr-only">{repo.name}</span>
              →</a>
            </article>
          </div>
        </section>

        <section class="design-section grid gap-8 lg:grid-cols-2" aria-labelledby="adoption-title">
          <div>
            <p class="design-eyebrow">BUILT TO BE SHARED</p><h2
              id="adoption-title"
              class="text-2xl font-semibold tracking-tight"
            >
              A reference, not a screenshot.
            </h2><p class="design-lead">
              Adopt the design rules and verify the behavior in your own application. Frameworks may differ; visual roles and interaction expectations should remain consistent.
            </p><.link navigate={~p"/guidelines"} class="design-text-link mt-5 inline-block">Get the specification →</.link>
          </div>
          <ol class="space-y-5 rounded-xl border border-outline-variant p-6">
            <li>
              <span class="design-small-label">01 / IDENTIFY</span><p class="mt-1 text-sm">
                Record the specification revision and your component versions.
              </p>
            </li>
            <li>
              <span class="design-small-label">02 / MAP</span><p class="mt-1 text-sm">
                Map semantic tokens, components, themes, and interaction states.
              </p>
            </li>
            <li>
              <span class="design-small-label">03 / VERIFY</span><p class="mt-1 text-sm">
                Check real workflows, both themes, keyboard use, and recovery states.
              </p>
            </li>
          </ol>
        </section>
      </div>
    </Layouts.home>
    """
  end
end
