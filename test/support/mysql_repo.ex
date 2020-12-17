defmodule EctoRawSQLHelpers.MySQLRepoForTest do
  use Ecto.Repo,
      otp_app: :ecto_raw_sql_helpers,
      adapter: Ecto.Adapters.MyXQL
end
