defmodule Tobex.Repo do
  use Ecto.Repo,
    otp_app: :tobex,
    adapter: Ecto.Adapters.Postgres
end
