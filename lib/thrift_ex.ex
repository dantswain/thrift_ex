defmodule ThriftEx do
  def to_binary(data,
                struct_info,
                protocol \\ :thrift_binary_protocol) do
    data
    |> to_binary_with_protocol(struct_info,
                               memory_protocol(protocol))
  end

  def to_binary_with_protocol(data, struct_info, protocol) do
    protocol
    |> :thrift_protocol.write({struct_info, data})
    |> binary_from_protocol
  end

  def memory_protocol(type) do
    {:ok, transport} = :thrift_memory_buffer.new
    {:ok, protocol} = type.new(transport)
    protocol
  end

  def from_binary(bin,
                  struct_info,
                  record, protocol \\ :thrift_binary_protocol) do
    {:ok, t} = :thrift_memory_buffer.new(:erlang.binary_to_list(bin))
    {:ok, p} = protocol.new(t)
    {_, {:ok, data}} = :thrift_protocol.read(p, struct_info, record)
    data
  end

  defp binary_from_protocol({p, :ok}) do
    binary_from_protocol(p)
  end
  defp binary_from_protocol(p) do
    {_, _, p0} = p
    {_, t, _, _} = p0
    {:transport, :thrift_memory_buffer, b} = t
    {:memory_buffer, bin} = b
    :erlang.iolist_to_binary(bin)
  end
end
