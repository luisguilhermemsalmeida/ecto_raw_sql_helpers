use Mix.Config

config :ecto_raw_sql_helpers, ecto_repos: [EctoRawSQLHelpers.RepoForTest]

config :ecto_raw_sql_helpers, EctoRawSQLHelpers.RepoForTest,
       username: "postgres",
       password: "postgres",
       database: "ecto_test",
       hostname: "localhost",
       pool: Ecto.Adapters.SQL.Sandbox,
       port: 5431,
       show_sensitive_data_on_connection_error: true,
       pool_size: 2
