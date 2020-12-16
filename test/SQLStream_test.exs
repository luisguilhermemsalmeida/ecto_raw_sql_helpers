defmodule EctoRawSQLHelpers.SQLStreamTest do
  use SQLCase

  alias EctoRawSQLHelpers.SQLStream

  test "query stream should return stream" do
    query_result = SQLStream.query(EctoRawSQLHelpers.RepoForTest, "SELECT * FROM generate_series(1, 3)")
                   |> Stream.map(fn %{"generate_series" => number} -> number + 1 end)
                   |> Enum.to_list()

    assert query_result == [2, 3, 4]
  end

  test "query stream using database cursor should work" do
    query_result = SQLStream.stream_query_from_database(EctoRawSQLHelpers.RepoForTest, "SELECT * FROM generate_series(1, 3)")
                   |> Stream.map(fn %{"generate_series" => number} -> number + 1 end)
                   |> Enum.to_list()

    assert query_result == [2, 3, 4]
  end
end
