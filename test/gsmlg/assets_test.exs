defmodule Gsmlg.AssetsTest do
  use ExUnit.Case, async: true

  test "development watcher uses the production profile source and resolution settings" do
    config =
      Path.expand("../../config/config.exs", __DIR__)
      |> Config.Reader.read!(env: :dev, target: :host)
      |> Keyword.fetch!(:duskmoon_bundler)

    profile = Keyword.fetch!(config, :gsmlg)
    options = Gsmlg.Assets.watcher_options(profile, config)

    assert options[:root] == profile[:root]
    assert options[:watch_dirs] == profile[:server][:watch_dirs]
    assert options[:tailwind_css] == profile[:tailwind][:css]
    assert options[:tailwind_sources] == profile[:tailwind][:sources]
    assert options[:tailwind_outdir] == Path.join(profile[:outdir], "css")
    assert options[:resolve_dirs] == config[:resolve_dirs]
    assert options[:target] == config[:target]
    assert options[:tailwind]
  end

  test "explicit watcher options override profile defaults" do
    profile = [
      root: "assets",
      outdir: "priv/static/assets",
      server: [watch_dirs: ["assets"]],
      tailwind: [css: "assets/app.css", sources: [%{base: "lib", pattern: "**/*.heex"}]]
    ]

    options =
      Gsmlg.Assets.watcher_options(profile, [resolve_dirs: ["node_modules"], target: :es2022],
        name: Gsmlg.Assets.DuskmoonBundlerWatcher,
        watch_dirs: ["custom"]
      )

    assert options[:name] == Gsmlg.Assets.DuskmoonBundlerWatcher
    assert options[:watch_dirs] == ["custom"]
    assert options[:tailwind_sources] == profile[:tailwind][:sources]
  end
end
