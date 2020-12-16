defmodule EctoRawSQLHelpers.SQL do
  import PipeOperators.SkipOnErrorPipe

  alias EctoRawSQLHelpers.DatabaseResponseParser
  alias EctoRawSQLHelpers.AdapterSQLExecutor

  def query(repo_or_pid, sql, params \\ [], options \\ []) do
    AdapterSQLExecutor.adapter_query(repo_or_pid, sql, params, options)
    ~> DatabaseResponseParser.rows_as_maps(options)
    ~> Enum.to_list()
  end

  def query_get_single_result(repo_or_pid, sql, params \\ [], options \\ []) do
    query(repo_or_pid, sql, params, options)
    ~> case do
      [first | []] -> first
      [_first | tail] -> {:error, "query_get_single_result_as_map returned more than one row, #{Enum.count(tail) + 1} rows returned"}
      _ -> nil
    end
  end

  def affecting_statement(repo_or_pid, sql, params \\ [], options \\ []) do
    AdapterSQLExecutor.adapter_query(repo_or_pid, sql, params, options)
    ~> DatabaseResponseParser.number_of_affected_rows
  end

  def affecting_statement_and_return_rows(repo_or_pid, sql, params \\ [], options \\ []) do
    AdapterSQLExecutor.adapter_query(repo_or_pid, sql, params, options)
    ~> DatabaseResponseParser.rows_as_maps(options)
    ~> Enum.to_list()
  end

  def affecting_statement_and_return_single_row(repo_or_pid, sql, params \\ [], options \\ []) do
    affecting_statement_and_return_rows(repo_or_pid, sql, params, options)
    ~> case do
      [first | []] -> first
      [_first | tail] -> {:error, "affecting_statement_and_return_single_row returned more than one row, #{Enum.count(tail) + 1} rows returned"}
      _ -> nil
    end
  end
end
