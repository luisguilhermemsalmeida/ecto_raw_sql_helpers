defmodule EctoRawSqlHelpers.SQLTest do
  use ExUnit.Case

  alias EctoRawSqlHelpers.SQL
  alias EctoRawSqlHelpers.SQLStream

  test "query should return list of maps" do
    query_result = SQL.query(EctoRawSQLHelpers.RepoForTest, "SELECT * FROM generate_series(1, 2)")
    assert query_result == [%{"generate_series" => 1}, %{"generate_series" => 2}]

    query_result = SQL.query(EctoRawSQLHelpers.RepoForTest, "SELECT * FROM generate_series(1, 2)", [], [column_names_as_atoms: true])
    assert query_result == [%{generate_series: 1}, %{generate_series: 2}]
  end

  test "query stream should return stream" do
    query_result = SQLStream.query(EctoRawSQLHelpers.RepoForTest, "SELECT * FROM generate_series(1, 3)", [], [column_names_as_atoms: true])
                   |> Stream.map(fn %{generate_series: numero} -> numero + 1 end)
                   |> Enum.to_list()

    assert query_result == [2, 3, 4]
  end

  test "query stream using database cursor should work" do
    query_result = SQLStream.stream_from_database(EctoRawSQLHelpers.RepoForTest, "SELECT * FROM generate_series(1, 3)", [], [column_names_as_atoms: true])
                   |> Stream.map(fn %{generate_series: numero} -> numero + 1 end)
                   |> Enum.to_list()

    assert query_result == [2, 3, 4]
  end
end
