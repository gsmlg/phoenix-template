defmodule Gsmlg.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Gsmlg.RuntimeRequirements.check!()

    children = [
      Gsmlg.Repo,
      {Phoenix.SessionProcess, []},
      {DNSCluster, query: Application.get_env(:gsmlg, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Gsmlg.PubSub},
      GsmlgWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Gsmlg.Supervisor)
  end

  @impl true
  def config_change(changed, _new, removed) do
    GsmlgWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
