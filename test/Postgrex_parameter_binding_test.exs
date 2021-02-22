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
       "INSERT INTO test (id, value) VALUES (:id, :value), (10, 'some value')",
       %{id: 5, value: "some string"}
    )

    assert affected_rows == 2

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
       %{ids: [5, 10]},
       column_names_as_atoms: true
    )

    assert query_result == [
      %{id: 5},
      %{id: 10},
    ]

    query_result = SQL.query(
      EctoRawSQLHelpers.PostgresRepoForTest,
       "SELECT 1.0::integer as number",
       %{},
       column_names_as_atoms: true
    )

    assert query_result == [
      %{number: 1},
    ]
  end

  test "Postgrex UUID handling" do
    Ecto.Adapters.SQL.query!(
      EctoRawSQLHelpers.PostgresRepoForTest,
      """
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
      """
    )

    Ecto.Adapters.SQL.query!(
      EctoRawSQLHelpers.PostgresRepoForTest,
      """
        CREATE TABLE test_uuid (
          id UUID PRIMARY KEY,
          value TEXT
        )
      """
    )

    affected_rows = SQL.affecting_statement(
      EctoRawSQLHelpers.PostgresRepoForTest,
       "INSERT INTO test_uuid (id, value) VALUES (:id, :value)",
       %{id: "fd942ed4-3f0a-4cb3-be4c-12bfae3c56df", value: "some string"}
    )

    assert affected_rows == 1

    row = SQL.query_get_single_result(
      EctoRawSQLHelpers.PostgresRepoForTest,
       "SELECT * FROM test_uuid"
    )

    assert row == %{
      id: "fd942ed4-3f0a-4cb3-be4c-12bfae3c56df", value: "some string"
    }

  end

  setup do
    Application.put_env(:ecto_raw_sql_helpers, :column_names_as_atoms, true)
    on_exit(fn ->
      Application.delete_env(:ecto_raw_sql_helpers, :column_names_as_atoms)
    end)
    :ok
  end
end
