defmodule Gsmlg.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository, not set
      # Gsmlg.Repo,
      # Start the endpoint when the application starts
      GsmlgWeb.Endpoint,
      {Phoenix.PubSub, [name: Gsmlg.PubSub, adapter: Phoenix.PubSub.PG2]}
      # Starts a worker by calling: Gsmlg.Worker.start_link(arg)
      # {Gsmlg.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gsmlg.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GsmlgWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
