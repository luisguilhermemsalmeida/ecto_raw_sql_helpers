defmodule EctoRawSQLHelpers.NamedParameterTranslatorTest do
  use ExUnit.Case

  alias EctoRawSQLHelpers.NamedParameterTranslator

  test "named parameter translator should translate Postgres query" do
    {sql, params} = NamedParameterTranslator.translate_named_parameters(
      Ecto.Adapters.Postgres,
      "SELECT :one, :two, :one",
      %{one: 1, two: 2},
      []
    )

    assert sql == "SELECT $1, $2, $3"
    assert params == [1, 2, 1]
  end

  test "named parameter translator should translate MyXQL query" do
    {sql, params} = NamedParameterTranslator.translate_named_parameters(
      Ecto.Adapters.MyXQL,
      "SELECT :one, :two, :one",
      %{one: 1, two: 2},
      []
    )

    assert sql == "SELECT ?, ?, ?"
    assert params == [1, 2, 1]
  end
end
