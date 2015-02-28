defmodule ThriftEx.MemoryTransport do
  def new do
    {:ok, transport} = :thrift_memory_buffer.new
    transport
  end

  def new(data) do
    {:ok, transport} = :thrift_memory_buffer.new(:erlang.binary_to_list(data))
    transport
  end

  def buffer_contents(transport) do
    {:transport, :thrift_memory_buffer, {:memory_buffer, buffer}} = transport
    buffer
  end
end
