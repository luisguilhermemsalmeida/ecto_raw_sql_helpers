if Code.ensure_loaded?(Postgrex) do
 Postgrex.Types.define(
    EctoRawSQLHelpers.Postgrex.CustomUUIDType,
    [EctoRawSQLHelpers.Postgrex.CustomUUID] ++ Ecto.Adapters.Postgres.extensions(),
    []
  )
end
