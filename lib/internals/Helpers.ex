defmodule EctoRawSQLHelpers.Helpers do
  def string_to_atom_if_enabled(string, options) do
    is_enabled?(options)
    |> case do
        false -> string
        true -> String.to_atom(string)
     end
  end

  defp is_enabled?(options) do
    Keyword.get(options, :column_names_as_atoms)
    |> case do
      nil -> Application.get_env(:ecto_raw_sql_helper, :column_names_as_atoms, false)
      value -> value
     end
  end
end
