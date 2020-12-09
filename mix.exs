defmodule EctoRawSqlHelpers.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_raw_sql_helpers,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, ">= 2.0.0", optional: true},
      {:postgrex, ">= 0.0.0", optional: true},
      {:myxql, ">= 0.4.0", optional: true}
    ]
  end
end
