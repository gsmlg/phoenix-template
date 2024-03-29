defmodule Gsmlg.Mixfile do
  use Mix.Project

  def project do
    [
      app: :gsmlg,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Gsmlg.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_live_view, "~> 0.17.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:guardian, "~> 2.0"},
      {:httpoison, "~> 1.8.0"},
      {:jason, "~> 1.0"},
      {:distillery, "~> 2.1.1", runtime: false},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
