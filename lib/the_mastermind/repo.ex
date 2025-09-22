defmodule TheMastermind.Repo do
  use Ecto.Repo,
    otp_app: :the_mastermind,
    adapter: Ecto.Adapters.Postgres
end
