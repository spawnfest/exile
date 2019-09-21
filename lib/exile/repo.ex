defmodule Exile.Repo do
  use Ecto.Repo,
    otp_app: :exile,
    adapter: Ecto.Adapters.Postgres
end
