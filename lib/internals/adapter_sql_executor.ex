defmodule EctoRawSQLHelpers.AdapterSQLExecutor do
  alias EctoRawSQLHelpers.NamedParameterTranslator

  def adapter_query(repo_or_pid, sql, params \\ [], opts \\ [])
  def adapter_query(repo_or_pid, sql, params, opts) when is_map(params) do
    {sql, params} = get_database_adapter(repo_or_pid)
    |> NamedParameterTranslator.translate_named_parameters(sql, params, opts)

    adapter_query(repo_or_pid, sql, params, opts)
  end
  def adapter_query(repo_or_pid, sql, params, opts) do
    {adapter_sql_function, opts} = Keyword.pop(opts, :adapter_sql_function, &Ecto.Adapters.SQL.query/4)
    adapter_sql_function.(repo_or_pid, sql, params, opts)
  end

  defp get_database_adapter(repo_module) when is_atom(repo_module) do
    repo_module.__adapter__()
  end
  defp get_database_adapter(repo_pid) when is_pid(repo_pid) do
    Ecto.Adapter.lookup_meta(repo_pid).repo.__adapter__()
  end
end
