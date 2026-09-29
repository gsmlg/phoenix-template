defmodule Gsmlg.Repo do
  use Ecto.Repo,
    otp_app: :gsmlg,
    adapter: Ecto.Adapters.Postgres
end
