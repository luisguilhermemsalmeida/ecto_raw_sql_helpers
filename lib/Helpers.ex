defmodule EctoRawSqlHelpers.Helpers do
  def adapter_query(repo_or_pid, sql, params \\ [], opts \\ []) do
    {adapter_sql_function, opts} = Keyword.pop(opts, :adapter_sql_function, &Ecto.Adapters.SQL.query/4)
    adapter_sql_function.(repo_or_pid, sql, params, opts)
  end

  def rows_as_maps({:ok, %{columns: columns, rows: rows}}, options) do
    rows
    |> Stream.map(&convert_row_to_map(&1, columns, options))
  end
  def rows_as_maps(anything_else, _options) do
    anything_else
  end

  def number_of_affected_rows({:ok, %{num_rows: rows}}) do
    rows
  end
  def number_of_affected_rows(anything_else) do
   anything_else
  end

  def convert_row_to_map(row, columns, options) do
    columns
    |> Enum.map(&convert_column_names_to_atom_if_enabled(&1, options))
    |> Enum.zip(row)
    |> Enum.into(%{})
  end

  defp convert_column_names_to_atom_if_enabled(column, options) do
    Keyword.get(options, :column_names_as_atoms)
    |> case do
      nil -> Application.get_env(:ecto_raw_sql_helper, :column_names_as_atoms, false)
      value -> value
     end
    |> case do
        false -> column
        true -> String.to_atom(column)
     end
  end
end
