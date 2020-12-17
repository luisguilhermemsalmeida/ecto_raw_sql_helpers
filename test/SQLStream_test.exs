defmodule EctoRawSQLHelpers.SQLStreamTest do
  use ExUnit.Case, async: false
  alias EctoRawSQLHelpers.SQLStream

  test "query stream should return stream" do
    query_result = SQLStream.query(EctoRawSQLHelpers.PostgresRepoForTest, "SELECT * FROM generate_series(1, 3)")
                   |> Stream.map(fn %{"generate_series" => number} -> number + 1 end)
                   |> Enum.to_list()

    assert query_result == [2, 3, 4]
  end

  test "query stream using database cursor should work" do
    query_result = SQLStream.stream_query_from_database(EctoRawSQLHelpers.PostgresRepoForTest, "SELECT * FROM generate_series(1, 3)")
                   |> Stream.map(fn %{"generate_series" => number} -> number + 1 end)
                   |> Enum.to_list()

    assert query_result == [2, 3, 4]
  end

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(EctoRawSQLHelpers.PostgresRepoForTest, sandbox: false)
    Ecto.Adapters.SQL.Sandbox.mode(EctoRawSQLHelpers.PostgresRepoForTest, {:shared, self()})
    :ok
  end
end
