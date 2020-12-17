defmodule SQLCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case, async: false
    end
  end

  setup do
    [
      EctoRawSQLHelpers.PostgresRepoForTest,
      EctoRawSQLHelpers.MySQLRepoForTest
    ]
    |> Enum.each(&setup_database_for_tests/1)

    :ok
  end

  defp setup_database_for_tests(database) do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(database)
    Ecto.Adapters.SQL.Sandbox.mode(database, {:shared, self()})
  end
end
