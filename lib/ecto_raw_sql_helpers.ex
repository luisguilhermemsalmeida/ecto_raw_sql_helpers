defmodule EctoRawSqlHelpers.SQL do
  def query(repo_or_pid, sql, params \\ [], opts \\ []) do
    adapter_query(repo_or_pid, sql, params, opts)
    |> rows_as_maps
  end

  def query_get_single_result(repo_or_pid, sql, params \\ [], opts \\ []) do
    case query_get_result_as_maps(repo_or_pid, sql, params, opts) do
      [first | []] -> first
      [_first | tail] -> {:error, "query_get_single_result_as_map returned more than one row, #{Enum.count(tail) + 1} rows returned"}
      _ -> nil
    end
  end

  def affecting_statement(repo_or_pid, sql, params \\ [], opts \\ []) do
    adapter_query(repo_or_pid, sql, params, opts)
    |> number_of_affected_rows
  end

  # Useful for postgres `returning` option on inserts
  def affecting_statement_and_return_rows(repo_or_pid, sql, params \\ [], opts \\ []) do
    adapter_query(repo_or_pid, sql, params, opts)
    |> rows_as_maps
  end

  # Useful for postgres `returning` option on inserts
  def affecting_statement_and_return_single_row(repo_or_pid, sql, params \\ [], opts \\ []) do
    case affecting_statement_and_return_rows(repo_or_pid, sql, params, opts) do
      [first | []] -> first
      [_first | tail] -> {:error, "query_get_single_result_as_map returned more than one row, #{Enum.count(tail) + 1} rows returned"}
      _ -> nil
    end
  end

  defp adapter_query(repo_or_pid, sql, params \\ [], opts \\ []) do
    {adapter_sql_function, opts} = Keyword.pop(opts, :adapter_sql_function, &Ecto.Adapters.SQL.query/4)
    adapter_sql_function.(repo_or_pid, sql, params, opts)
  end

  defp rows_as_maps({:ok, %{columns: columns, rows: rows}}) do
    rows
    |> Enum.map(&convert_row_to_map(&1, columns))
  end
  defp rows_as_maps(anything_else), do: anything_else

  defp number_of_affected_rows({:ok, %{num_rows: rows}}) do
    rows
  end
  defp number_of_affected_rows(anything_else), do: anything_else

  defp convert_row_to_map(row, columns) do
    columns
    |> Enum.map(&String.to_atom/1)
    |> Enum.zip(row)
    |> Enum.into(%{})
  end
end
