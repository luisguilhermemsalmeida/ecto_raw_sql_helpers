defmodule EctoRawSqlHelpers.SQL do
  import EctoRawSqlHelpers.Helpers

  def query(repo_or_pid, sql, params \\ [], options \\ []) do
    adapter_query(repo_or_pid, sql, params, options)
    |> rows_as_maps(options)
    |> Enum.to_list()
  end

  def query_get_single_result(repo_or_pid, sql, params \\ [], options \\ []) do
    case query(repo_or_pid, sql, params, options) do
      [first | []] -> first
      [_first | tail] -> {:error, "query_get_single_result_as_map returned more than one row, #{Enum.count(tail) + 1} rows returned"}
      _ -> nil
    end
  end

  def affecting_statement(repo_or_pid, sql, params \\ [], options \\ []) do
    adapter_query(repo_or_pid, sql, params, options)
    |> number_of_affected_rows
  end

  def affecting_statement_and_return_rows(repo_or_pid, sql, params \\ [], options \\ []) do
    adapter_query(repo_or_pid, sql, params, options)
    |> rows_as_maps(options)
    |> Enum.to_list()
  end

  def affecting_statement_and_return_single_row(repo_or_pid, sql, params \\ [], options \\ []) do
    case affecting_statement_and_return_rows(repo_or_pid, sql, params, options) do
      [first | []] -> first
      [_first | tail] -> {:error, "query_get_single_result_as_map returned more than one row, #{Enum.count(tail) + 1} rows returned"}
      _ -> nil
    end
  end
end
