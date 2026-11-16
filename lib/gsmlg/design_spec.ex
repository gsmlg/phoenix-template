defmodule Gsmlg.DesignSpec do
  @moduledoc "The canonical specification embedded at compile time for release-safe export."
  @path Path.expand("../../DESIGN.md", __DIR__)
  @external_resource @path
  @markdown File.read!(@path)
  @fingerprint :crypto.hash(:sha256, @markdown) |> Base.encode16(case: :lower)

  def markdown, do: @markdown
  def fingerprint, do: @fingerprint

  def page_markdown do
    @markdown
    |> String.replace(~r/^# Shared UI Design Specification\n\n/, "")
  end
end
