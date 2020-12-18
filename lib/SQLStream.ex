defmodule EctoRawSQLHelpers.SQLStream do
  alias EctoRawSQLHelpers.DatabaseResponseParser
  alias EctoRawSQLHelpers.AdapterSQLExecutor
  alias EctoRawSQLHelpers.StreamServer
  require IEx

  def query(repo_or_pid, sql, params \\ [], options \\ []) do
    Stream.resource(
      fn -> AdapterSQLExecutor.adapter_query(repo_or_pid, sql, params, options) end,
      fn
        {:ok, %{columns: columns, rows: rows}} -> {[DatabaseResponseParser.convert_row_to_map(hd(rows), columns, options)], {columns, tl(rows)}}
        {columns, [row|tail]} -> {[DatabaseResponseParser.convert_row_to_map(row, columns, options)], {columns, tail}}
        {_columns, []} -> {:halt, :ok}
      end,
      fn _ -> :ok end
    )
  end

  def cursor(repo_or_pid, sql, params \\ [], options \\ []) do
    Stream.resource(
      fn -> StreamServer.initialize_stream_server_and_wait_for_demand(repo_or_pid, sql, params, options) end,
      fn pid -> handle_client_demand(pid, options) end,
      fn _ -> :ok end
    )
  end

  defp handle_client_demand(pid, options) do
    send(pid, %StreamServer.StreamRequest{client_pid: self(), instruction: :next_page})
    receive do
      %StreamServer.StreamResponse{server_pid: ^pid, state: :ok, data: data} -> {stream_rows_as_maps(data, options), pid}
      %StreamServer.StreamResponse{server_pid: ^pid, state: :finished} -> {:halt, :ok}
    end
  end

  defp stream_rows_as_maps(%{columns: columns, rows: rows}, options) do
    rows
    |> Enum.map(&DatabaseResponseParser.convert_row_to_map(&1, columns, options))
  end
end
