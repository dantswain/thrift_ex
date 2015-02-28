defmodule ThriftExTest do
  require ThriftExTest.Bonk

  use ExUnit.Case
  doctest ThriftEx

  @bonk ThriftExTest.Bonk.bonk(message: "hello, world", type: -1)
  @bonk_binary <<11, 0, 1, 0, 0, 0, 12, 104, 101, 108, 108, 111, 44, 32, 119,
  111, 114, 108, 100, 8, 0, 2, 255, 255, 255, 255, 0>>

  test "serialize bonk" do
    b = ThriftEx.BinaryProtocol.serialize(@bonk, ThriftExTest.Bonk)
    assert b == @bonk_binary
  end

  test "deserialize bonk" do
    b = ThriftEx.BinaryProtocol.deserialize(@bonk_binary, ThriftExTest.Bonk, :Bonk)
    assert b == @bonk
  end
end
