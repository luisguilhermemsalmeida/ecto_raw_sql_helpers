defmodule EctoRawSQLHelpers.DatabaseResponseParser do
  alias EctoRawSQLHelpers.Helpers
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
    |> Enum.map(&Helpers.string_to_atom_if_enabled(&1, options))
    |> Enum.zip(row)
    |> Enum.into(%{})
  end
end
