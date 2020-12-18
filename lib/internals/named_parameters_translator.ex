defmodule EctoRawSQLHelpers.NamedParameterTranslator do
  @split_regex ~r/:\w+/

  def translate_named_parameters(adapter, sql, params, options) do
    @split_regex
    |> Regex.split(sql, trim: true, include_captures: true)
    |> Enum.map(&is_parameter/1)
    |> Enum.reduce({_sql = "", _parameter_list = []}, &translate_query_and_params_to_provider_placeholder(&1, &2, params, adapter, options))
  end

  defp is_parameter(string) do
    %{is_parameter: Regex.match?(@split_regex, string), sql: string}
  end

  defp translate_query_and_params_to_provider_placeholder(%{is_parameter: false, sql: sql_chunk}, {sql, param_list}, _parameters_map, _adapter, _options) do
    {sql <> sql_chunk, param_list}
  end
  defp translate_query_and_params_to_provider_placeholder(
    %{is_parameter: true, sql: named_parameter},
    {sql, param_list},
    parameters_map,
    adapter,
    options
  ) do
    parameter = find_parameter_or_raise!(named_parameter, parameters_map, options)

    {
      sql <> adapter_placeholder(adapter, param_list, parameter),
      param_list ++ parameter_to_list(parameter)
    }
  end

  defp adapter_placeholder(Ecto.Adapters.Postgres, param_list, {:in, values}) do
    previous_parameters = Enum.count(param_list) + 1
    in_clause_parameters = Enum.count(values)

    previous_parameters..in_clause_parameters
    |> Enum.map(fn index -> "$" <> to_string(index) end)
    |> Enum.join(",")
  end
  defp adapter_placeholder(Ecto.Adapters.Postgres, param_list, _parameter) do
    "$" <> to_string(Enum.count(param_list) + 1)
  end

  defp adapter_placeholder(Ecto.Adapters.MyXQL, _param_list, {:in, values}) do
    in_clause_parameters = Enum.count(values)

    1..in_clause_parameters
    |> Enum.map(fn _ -> "?" end)
    |> Enum.join(",")
  end
  defp adapter_placeholder(Ecto.Adapters.MyXQL, _param_list, _parameter) do
    "?"
  end

  defmodule SQLParameterNotSetException do
    defexception [:parameter_name]

    def message(exception) do
      "Parameter #{exception.parameter_name} not found on bind values"
    end
  end

  defp find_parameter_or_raise!(":" <> named_parameter, parameters_map, _options) do
    parameters_map
    |> Map.has_key?(String.to_atom(named_parameter))
    |> case do
      false -> raise SQLParameterNotSetException, parameter_name: named_parameter
      true -> Map.fetch!(parameters_map, String.to_atom(named_parameter))
    end
  end

  defp parameter_to_list({:in, values}) do
    values
  end
  defp parameter_to_list(values) do
    [values]
  end
end
