defmodule Gsmlg.DesignCatalog do
  @moduledoc "Curated sources for the shared design reference."

  @layers [
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
      repository: "duskmoon-web",
      layer: "CSS foundation",
      package: "@duskmoon-dev/core",
      description:
        "Framework-independent component styles, semantic utilities, and sunshine / moonlight themes with Tailwind integration.",
      usage: "Use the same visual vocabulary in every web application.",
      revision: "v2.0.0-rc.3",
      source: "packages/css/core/README.md",
      demo: "/components#core"
    },
    %{
      id: "elements",
      number: "03",
      name: "Web Components",
      repository: "duskmoon-web",
      layer: "Browser primitives",
      package: "@duskmoon-dev/elements",
      description:
        "Interactive custom elements with encapsulated behavior. Register the complete collection through one aggregate entry.",
      usage: "Use browser-native elements across framework boundaries.",
      revision: "v2.0.0-rc.3",
      source: "packages/elements/elements/README.md",
      demo: "/components#elements"
    },
    %{
      id: "react",
      number: "04",
      name: "React components",
      repository: "duskmoon-web",
      layer: "React integration",
      package: "@duskmoon-dev/components",
      description:
        "React components and compositions using the shared Core styles, with state and events owned by React.",
      usage: "Compose React interfaces without inventing another design system.",
      revision: "v2.0.0-rc.3",
      source: "packages/react/components/README.md",
      demo: "/components#react"
    },
    %{
      id: "phoenix",
      number: "05",
      name: "Phoenix components",
      repository: "duskmoon-web",
      layer: "HEEx & LiveView",
      package: "duskmoon_phoenix",
      description:
        "Native HEEx function components and LiveView hooks for forms, navigation, and server-connected workflows.",
      usage: "Build validated forms, feedback, and live application flows.",
      revision: "v2.0.0-rc.3",
      source: "phoenix/apps/duskmoon_phoenix/README.md",
      demo: "/components#phoenix"
    }
  ]

  def layers, do: @layers

  def source_url(layer),
    do:
      "https://github.com/duskmoon-dev/#{layer.repository}/blob/#{layer.revision}/#{layer.source}"
end
