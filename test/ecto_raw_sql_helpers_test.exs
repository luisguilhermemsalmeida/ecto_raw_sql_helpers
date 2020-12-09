defmodule EctoRawSqlHelpersTest do
  use ExUnit.Case
  doctest EctoRawSqlHelpers

  test "greets the world" do
    assert EctoRawSqlHelpers.hello() == :world
  end
end
