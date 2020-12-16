defmodule SQLCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case
    end
  end

  setup tags do
    Ecto.Adapters.SQL.Sandbox.mode(EctoRawSQLHelpers.RepoForTest, :manual)
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoRawSQLHelpers.RepoForTest)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EctoRawSQLHelpers.RepoForTest, {:shared, self()})
    end

    :ok
  end
end
