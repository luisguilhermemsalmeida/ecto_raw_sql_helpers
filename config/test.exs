use Mix.Config

config :ecto_raw_sql_helpers, ecto_repos: [
  EctoRawSQLHelpers.PostgresRepoForTest,
  EctoRawSQLHelpers.MySQLRepoForTest,
]

config :ecto_raw_sql_helpers, EctoRawSQLHelpers.PostgresRepoForTest,
       username: "root",
       password: "root",
       database: "root",
       hostname: "localhost",
       pool: Ecto.Adapters.SQL.Sandbox,
       port: 5430,
       show_sensitive_data_on_connection_error: true,
       pool_size: 1,
       types: EctoRawSQLHelpers.Postgrex.CustomUUIDType

config :ecto_raw_sql_helpers, EctoRawSQLHelpers.MySQLRepoForTest,
      username: "root",
      password: "root",
      database: "root",
      hostname: "localhost",
      pool: Ecto.Adapters.SQL.Sandbox,
      port: 3300,
      show_sensitive_data_on_connection_error: true,
      pool_size: 1
