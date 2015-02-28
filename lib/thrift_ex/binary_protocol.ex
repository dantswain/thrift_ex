defmodule ThriftEx.BinaryProtocol do
  def new(transport \\ ThriftEx.MemoryTransport.new) do
    {:ok, protocol} = :thrift_binary_protocol.new(transport)
    protocol
  end

  def write(protocol, {struct_info, data}) do
    :thrift_protocol.write(protocol, {struct_info, data})
  end

  def read(protocol, struct_info, to_obj) do
    :thrift_protocol.read(protocol, struct_info, to_obj)
  end

  def serialize(data, struct_module, transport \\ ThriftEx.MemoryTransport.new) do
    new(transport)
    |> write({struct_module.struct_info, data})
    |> pipe_ok
    |> binary_data
  end

  def deserialize(binary, struct_module, to_obj, transport_type \\ ThriftEx.MemoryTransport) do
    new(transport_type.new(binary))
    |> read(struct_module.struct_info, to_obj)
    |> result_obj
  end

  def binary_data(protocol, transport_type \\ ThriftEx.MemoryTransport) do
    protocol
    |> transport
    |> transport_type.buffer_contents
    |> :erlang.iolist_to_binary
  end

  def transport(protocol) do
    # relies on denomralizing the underlying records..
    {_, _, {_, transport, _, _}} = protocol
    transport
  end

  defp pipe_ok({v, :ok}) do
    v
  end

  defp result_obj({_, {:ok, obj}}) do
    obj
  end
end
