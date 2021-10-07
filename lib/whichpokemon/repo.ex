defmodule Whichpokemon.Repo do
  use Ecto.Repo,
    otp_app: :whichpokemon,
    adapter: Ecto.Adapters.Postgres
end
