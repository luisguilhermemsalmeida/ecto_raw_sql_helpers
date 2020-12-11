defmodule EctoRawSQLHelpers.RepoForTest do
  use Ecto.Repo,
      otp_app: :ecto_raw_sql_helpers,
      adapter: Ecto.Adapters.Postgres
end
