defmodule GsmlgWeb.SidebarBootstrap do
  @moduledoc false
  use Hologram.Component

  @source_path Path.expand("../../../assets/js/sidebar_bootstrap.js", __DIR__)
  @external_resource @source_path
  @source File.read!(@source_path)

  def source, do: @source

  @impl Hologram.Component
  def template do
    Hologram.Template.sigil_HOLO(
      unquote("<script>{%raw}\n#{@source}\n{/raw}</script>"),
      []
    )
  end
end
