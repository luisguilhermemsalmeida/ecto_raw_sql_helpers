if Code.ensure_loaded?(Postgrex) do
  defmodule EctoRawSQLHelpers.Postgrex.CustomUUID do
    import Postgrex.BinaryUtils, warn: false
    use Postgrex.BinaryExtension, send: "uuid_send"

    def encode(_) do
      quote location: :keep do
        uuid when is_binary(uuid) and byte_size(uuid) == 16 ->
          [<<16::int32>> | uuid]
        << a::64, 45::8, b::32, 45::8, c::32, 45::8, d::32, 45::8, e::96 >> ->
          {:ok, uuid } = String.upcase(<< a::64, b::32, c::32, d::32, e::96 >>)
          |> Base.decode16
          [<<16 :: int32>> | uuid]
        other ->
          raise DBConnection.EncodeError, Postgrex.Utils.encode_msg(other, "a binary of 16 bytes or a valid UUID string representation")
      end
    end
    def decode(_) do
      quote location: :keep do
        <<16::int32, uuid::binary-16>> -> Ecto.UUID.load(uuid) |> elem(1)
      end
    end
  end
end
