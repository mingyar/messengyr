defmodule Messengyr.Repo do
  use Ecto.Repo,
    otp_app: :messengyr,
    adapter: Ecto.Adapters.Postgres
end
