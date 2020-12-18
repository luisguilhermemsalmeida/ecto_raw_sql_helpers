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
       "INSERT INTO test (value) VALUES (:id, :value), (10, 'some value')",
       %{id: 5, value: "some string"}
    )

    assert affected_rows == 1

    query_result = SQL.query_get_single_result(
      EctoRawSQLHelpers.PostgresRepoForTest,
       "SELECT value FROM test WHERE value = :value",
       %{value: "some string"},
       column_names_as_atoms: true
    )

    assert query_result == %{value: "some string"}

    query_result = SQL.query(
      EctoRawSQLHelpers.PostgresRepoForTest,
       "SELECT id FROM test WHERE id IN(:ids) ORDER BY id",
       %{ids: {:in, [5, 10]}},
       column_names_as_atoms: true
    )

    assert query_result == [
      %{id: 5},
      %{id: 10},
    ]

    query_result = SQL.query(
      EctoRawSQLHelpers.PostgresRepoForTest,
       "SELECT id FROM test WHERE id = ANY(:ids) ORDER BY id",
       %{ids: [5, 10],
       column_names_as_atoms: true
    )

    assert query_result == [
      %{id: 5},
      %{id: 10},
    ]
  end

  setup do
    Application.put_env(:ecto_raw_sql_helper, :column_names_as_atoms, true)
    on_exit(fn ->
      Application.delete_env(:ecto_raw_sql_helper, :column_names_as_atoms)
    end)
    :ok
  end
end
