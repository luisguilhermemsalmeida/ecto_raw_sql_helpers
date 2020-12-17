defmodule EctoRawSQLHelpers.PostgrexParameterBindingTest do
  use SQLCase

  alias EctoRawSQLHelpers.SQL

  test "Postgrex query with parameter binding" do
    SQL.affecting_statement(
      EctoRawSQLHelpers.PostgresRepoForTest,
       "CREATE TABLE IF NOT EXISTS test (id INT PRIMARY KEY, value VARCHAR(50))"
    )

    affected_rows = SQL.affecting_statement(
      EctoRawSQLHelpers.PostgresRepoForTest,
       "INSERT INTO test (value) VALUES (:value)",
       %{value: "some string"}
    )

    assert affected_rows == 1

    query_result = SQL.query_get_single_result(
      EctoRawSQLHelpers.PostgresRepoForTest,
       "SELECT value FROM test WHERE value = :value",
       %{value: "some string"},
       column_names_as_atoms: true
    )

    assert query_result == %{value: "some string"}
  end

  setup do
    Application.put_env(:ecto_raw_sql_helper, :column_names_as_atoms, true)
    on_exit(fn ->
      Application.delete_env(:ecto_raw_sql_helper, :column_names_as_atoms)
    end)
    :ok
  end
end
