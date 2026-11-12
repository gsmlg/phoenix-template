defmodule Gsmlg.MixProject do
  use Mix.Project

  def project do
    if String.to_integer(System.otp_release()) < 28, do: Mix.raise("Erlang/OTP >= 28 is required")

    [
      app: :gsmlg,
      version: "0.1.0",
      elixir: ">= 1.18.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers() ++ [:hologram],
      releases: [gsmlg: [steps: [:assemble, &strip_release_source_maps/1]]],
      listeners: [Phoenix.CodeReloader]
    ]
  end

  def application do
    [mod: {Gsmlg.Application, []}, extra_applications: [:logger, :runtime_tools]]
  end

  def cli, do: [preferred_envs: [precommit: :test]]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.8.15"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto, "~> 3.14.3"},
      {:ecto_sql, "~> 3.14"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.2.0"},
      {:lazy_html, ">= 0.1.0"},
      {:phoenix_duskmoon, "~> 10.1.1"},
      {:duskmoon_bundler, "~> 10.1.6", runtime: Mix.env() in [:dev, :test]},
      {:duskmoon_bundler_runtime, "~> 10.1.6"},
      {:duskmoon_hologram, "~> 10.1.6"},
      {:phoenix_session_process, "~> 1.0.1"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.12"},
      {:igniter, "~> 0.8", only: [:dev, :test], runtime: false}
    ]
  end

  defp install_assets(args) do
    File.cd!("assets", fn -> Mix.Task.run("npm.install", ["--frozen" | args]) end)
  end

  defp strip_release_source_maps(release) do
    for pattern <- ["**/*.map", "**/*.map.gz", "**/*.map.br"],
        file <- Path.wildcard(Path.join([release.path, "lib/gsmlg-*/priv/static", pattern])) do
      File.rm!(file)
    end

    release
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["compile", &install_assets/1],
      "assets.build": ["compile", "duskmoon_bundler.build gsmlg --tailwind --no-hash --no-minify"],
      "assets.deploy": ["duskmoon_bundler.build gsmlg --tailwind", "phx.digest"],
      precommit: [
        "compile --warnings-as-errors",
        "deps.unlock --check-unused",
        "format --check-formatted",
        "test"
      ]
    ]
  end
end
