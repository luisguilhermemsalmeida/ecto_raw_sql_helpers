defmodule EctoRawSQLHelpers.SQLTest do
  use SQLCase

  alias EctoRawSQLHelpers.SQL
  alias EctoRawSQLHelpers.SQLStream

  test "query should return list of maps" do
    query_result = SQL.query(EctoRawSQLHelpers.RepoForTest, "SELECT * FROM generate_series(1, 2)")
    assert query_result == [%{"generate_series" => 1}, %{"generate_series" => 2}]

    query_result = SQL.query(EctoRawSQLHelpers.RepoForTest, "SELECT * FROM generate_series(1, 2)", [], [column_names_as_atoms: true])
    assert query_result == [%{generate_series: 1}, %{generate_series: 2}]
  end

  test "query_get_single_return should return map" do
    query_result = SQL.query_get_single_result(EctoRawSQLHelpers.RepoForTest, "SELECT *, 'a' as a FROM generate_series(1, 1)")
    assert query_result == %{"generate_series" => 1, "a" => "a"}
  end

  test "query_get_single_return should nil when response is empty" do
    SQL.affecting_statement(EctoRawSQLHelpers.RepoForTest, "CREATE TABLE test (id INT PRIMARY KEY)")

    query_result = SQL.query_get_single_result(EctoRawSQLHelpers.RepoForTest, "SELECT * FROM test")
    assert query_result == nil
  end

  test "query_get_single_return should return :error tuple when response has more than one row" do
    query_result = SQL.query_get_single_result(EctoRawSQLHelpers.RepoForTest, "SELECT * FROM generate_series(1, 2)")
    assert query_result == {:error, "query_get_single_result_as_map returned more than one row, 2 rows returned"}
  end

  test "affecting_statement should return number of affected rows" do
    SQL.affecting_statement(EctoRawSQLHelpers.RepoForTest, "CREATE TABLE test (id INT PRIMARY KEY)")

    number_of_affected_rows = SQL.affecting_statement(EctoRawSQLHelpers.RepoForTest, "INSERT INTO test VALUES (1), (2)")
    assert number_of_affected_rows == 2
  end

  test "affecting_statement_and_return_rows should return rows as maps" do
    SQL.affecting_statement(EctoRawSQLHelpers.RepoForTest, "CREATE TABLE test (id INT PRIMARY KEY)")

    number_of_affected_rows = SQL.affecting_statement_and_return_rows(
      EctoRawSQLHelpers.RepoForTest,
      "INSERT INTO test VALUES (1), (2) returning id"
    )
    assert number_of_affected_rows == [%{"id" => 1},  %{"id" => 2}]
  end

  test "affecting_statement_and_return_single_row should return map" do
    SQL.affecting_statement(EctoRawSQLHelpers.RepoForTest, "CREATE TABLE test (id INT PRIMARY KEY)")

    number_of_affected_rows = SQL.affecting_statement_and_return_single_row(
      EctoRawSQLHelpers.RepoForTest,
      "INSERT INTO test VALUES (1) returning id"
    )
    assert number_of_affected_rows == %{"id" => 1}
  end

  test "affecting_statement_and_return_single_row should return :error tuple when result has more than one row" do
    SQL.affecting_statement(EctoRawSQLHelpers.RepoForTest, "CREATE TABLE test (id INT PRIMARY KEY)")

    number_of_affected_rows = SQL.affecting_statement_and_return_single_row(
      EctoRawSQLHelpers.RepoForTest,
      "INSERT INTO test VALUES (1), (2) returning id"
    )
    assert number_of_affected_rows == {:error, "affecting_statement_and_return_single_row returned more than one row, 2 rows returned"}
  end
end
