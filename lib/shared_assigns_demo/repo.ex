defmodule SharedAssignsDemo.Repo do
  use Ecto.Repo,
    otp_app: :shared_assigns_demo,
    adapter: Ecto.Adapters.SQLite3
end
