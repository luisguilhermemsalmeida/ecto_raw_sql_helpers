defmodule EctoRawSQLHelpers.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_raw_sql_helpers,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
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
      {:pipe_operators, git: "https://github.com/leveexpress/pipe_operators.git", branch: "main"},
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
end
