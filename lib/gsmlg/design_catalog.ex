defmodule Gsmlg.DesignCatalog do
  @moduledoc "Curated sources for the shared design reference."

  @repositories [
    %{
      id: "design",
      number: "01",
      name: "Design foundations",
      repository: "design",
      layer: "Token source",
      package: "@duskmoon-dev/design",
      description:
        "The shared language: color, typography, spacing, radii, and elevation. YAML sources generate platform-ready design tokens.",
      usage: "Start here when defining or aligning a visual system.",
      revision: "175c49dd86d173bf3bba5d8ca6a647ad42421a0f",
      source: "README.md",
      demo: "/guidelines"
    },
    %{
      id: "core",
      number: "02",
      name: "Core styles",
      repository: "duskmoonui",
      layer: "CSS foundation",
      package: "@duskmoon-dev/core",
      description:
        "Framework-independent component styles, semantic utilities, and sunshine / moonlight themes with Tailwind integration.",
      usage: "Use the same visual vocabulary in every web application.",
      revision: "12ca4f5c3b8e6f994da144d087c624e489e7ca7b",
      source: "README.md",
      demo: "/components#core"
    },
    %{
      id: "elements",
      number: "03",
      name: "Web Components",
      repository: "duskmoon-elements",
      layer: "Browser primitives",
      package: "@duskmoon-dev/elements",
      description:
        "Interactive custom elements with encapsulated behavior. Register the complete collection through one aggregate entry.",
      usage: "Use browser-native elements across framework boundaries.",
      revision: "4b8e3b97dcc6cc2be2e3967b3baf75b5ba7cb845",
      source: "packages/elements/README.md",
      demo: "/components#elements"
    },
    %{
      id: "react",
      number: "04",
      name: "React components",
      repository: "duskmoon-react",
      layer: "React integration",
      package: "@duskmoon-dev/components",
      description:
        "React components and compositions using the shared Core styles, with state and events owned by React.",
      usage: "Compose React interfaces without inventing another design system.",
      revision: "95704b4e8d39e1a30a5df1d7c16213dca938228b",
      source: "README.md",
      demo: "/components#react"
    },
    %{
      id: "phoenix",
      number: "05",
      name: "Phoenix components",
      repository: "phoenix-duskmoon-ui",
      layer: "HEEx & LiveView",
      package: "phoenix_duskmoon",
      description:
        "HEEx function components and LiveView hooks integrating Core styling and custom elements with server-connected workflows.",
      usage: "Build validated forms, feedback, and live application flows.",
      revision: "e89e7d01df936b4e5fac841a92a754eb65ba8803",
      source: "README.md",
      demo: "/components#phoenix"
    }
  ]

  def repositories, do: @repositories
  def repository_url(repository), do: "https://github.com/duskmoon-dev/#{repository.repository}"

  def source_url(repository),
    do: repository_url(repository) <> "/blob/#{repository.revision}/#{repository.source}"
end
