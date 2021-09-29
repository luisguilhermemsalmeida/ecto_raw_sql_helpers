defmodule EctoRawSQLHelpers.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_raw_sql_helpers,
      version: "0.1.2",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      package: package(),
      description: description(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps() do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:pipe_operators, "~> 0.1.1"},
      {:ecto_sql, ">= 2.0.0"},
      {:postgrex, ">= 0.0.0", only: [:test]},
      {:myxql, ">= 0.4.0", only: [:test]},
      {:telemetry_poller, "~> 0.4", only: [:test]}
    ]
  end

  defp aliases do
    [
      test: ["cmd docker-compose up -d", "cmd sleep 10", "ecto.create --quiet", "test"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/luisguilhermemsalmeida/ecto_raw_sql_helpers"}
    ]
  end

  defp description() do
    ~s"""
    EctoRawSQLHelpers aims to improve raw SQL support in Ecto by providing helper functions, such as:
    - Named parameters support
    - Response parsing (getting query results as lists of maps, number of rows affected on statements, etc)
    - Stream support for dealing with big result sets
    """
  end
end
