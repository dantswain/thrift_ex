defmodule ThriftExTest do
  require ThriftExTest.Bonk
  require ThriftExTest.Xtruct
  require ThriftExTest.Xtruct2

  use ExUnit.Case
  doctest ThriftEx

  @bonk ThriftExTest.Bonk.bonk(message: "hello, world", type: -1)
  @bonk_binary <<11, 0, 1, 0, 0, 0, 12, 104, 101, 108, 108, 111, 44, 32, 119,
  111, 114, 108, 100, 8, 0, 2, 255, 255, 255, 255, 0>>

  @xtruct ThriftExTest.Xtruct.xtruct(string_thing: "foobar",
                                     byte_thing: 123,
                                     i32_thing: 1234567,
                                     i64_thing: 12345678900)
  @xtruct_binary <<11, 0, 1, 0, 0, 0, 6, 102, 111, 111, 98, 97, 114, 3, 0, 4,
  123, 8, 0, 9, 0, 18, 214, 135, 10, 0, 11, 0, 0, 0, 2, 223, 220, 28, 52, 0>>

  @xtruct2 ThriftExTest.Xtruct2.xtruct2(byte_thing: 21,
                                        struct_thing: @xtruct,
                                        i32_thing: 7654321)
  @xtruct2_binary <<3, 0, 1, 21, 12, 0, 2, 11, 0, 1, 0, 0, 0, 6, 102, 111, 111,
  98, 97, 114, 3, 0, 4, 123, 8, 0, 9, 0, 18, 214, 135, 10, 0, 11, 0, 0, 0, 2,
  223, 220, 28, 52, 0, 8, 0, 3, 0, 116, 203, 177, 0>>

  test "serialize bonk" do
    b = ThriftEx.BinaryProtocol.serialize(@bonk, ThriftExTest.Bonk)
    assert b == @bonk_binary
  end

  test "deserialize bonk" do
    b = ThriftEx.BinaryProtocol.deserialize(@bonk_binary, ThriftExTest.Bonk)
    assert b == @bonk
  end

  test "serialize xtruct" do
    b = ThriftEx.BinaryProtocol.serialize(@xtruct, ThriftExTest.Xtruct)
    assert b == @xtruct_binary
  end

  test "deserialize xtruct" do
    b = ThriftEx.BinaryProtocol.deserialize(@xtruct_binary, ThriftExTest.Xtruct)
    assert b == @xtruct
  end

  test "serialize xtruct2" do
    b = ThriftEx.BinaryProtocol.serialize(@xtruct2, ThriftExTest.Xtruct2)
    assert b == @xtruct2_binary
  end

  test "deserialize xtruct2" do
    b = ThriftEx.BinaryProtocol.deserialize(@xtruct2_binary,
                                            ThriftExTest.Xtruct2)
    assert b == @xtruct2
  end
end
