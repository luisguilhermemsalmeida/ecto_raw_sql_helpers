defmodule EctoRawSqlHelpers.SQLStream do
  import EctoRawSqlHelpers.Helpers

  def query(repo_or_pid, sql, params \\ [], options \\ []) do
    Stream.resource(fn -> adapter_query(repo_or_pid, sql, params, options) end,
      fn
        {:ok, %{columns: columns, rows: rows}} -> {[convert_row_to_map(hd(rows), columns, options)], {columns, tl(rows)}}
        {columns, [row|tail]} -> {[convert_row_to_map(row, columns, options)], {columns, tail}}
        {_columns, []} -> {:halt, :ok}
      end,
      fn _ -> :ok end)
  end

  def stream_from_database(repo_or_pid, sql, params \\ [], options \\ []) do
    Stream.resource(fn -> spawn_link fn -> repo_or_pid.transaction(
                                        fn ->
                                          Ecto.Adapters.SQL.stream(repo_or_pid, sql, params, options)
                                          |> Enum.each(fn line ->
                                            receive do
                                              {:next, pid} ->
                                              send(pid, {:ok, line})
                                            end
                                          end)

                                          receive do
                                            {:next, pid} ->
                                              send(pid, {:finished})
                                          end
                                        end
                                      ) end end,
      fn
        pid ->
          send(pid, {:next, self()})
          receive do
            {:ok, line} -> {stream_rows_as_maps(line, options), pid}
            {:finished} -> {:halt, :ok}
            other ->  Process.send_after(self(), other, 100)
                      {[], pid}
          end
      end,
      fn _ -> :ok end)
  end

  defp stream_rows_as_maps(%{columns: columns, rows: rows}, options) do
    rows
    |> Enum.map(&convert_row_to_map(&1, columns, options))
  end
end
