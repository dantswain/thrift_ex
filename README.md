ThriftEx
========

**NOTE** It is recommended that you only use this library as a way to
pull in the Erlang Thrift library.  If you want to use Thrift in
Elixir, see [Thrash](https://github.com/dantswain/thrash) - a very
fast Thrift serializer/deserializer.

This is still WIP.  The intention is to create a dependency that can
be included in a mix.exs file (ultimately a hex package) to use
[Apache Thrift](https://thrift.apache.org/) in Elixir and Erlang
projects.

Usage (so far)
--------------

Include this project as a dependency in your thrift-based project:
```elixir
# in your mix.exs
defp deps do
  [ #...
    {:thrift_ex, git: "http://github.com/dantswain/thrift_ex"}
    #...
  ]
end
```

Then `mix deps.get && mix deps.compile`.

If you're building an Erlang project with mix, that might be all
that's needed.  You can use `mix thrift` (see below) to generate
Erlang code from your `.thrift` files, but all this will do is
run the thrift binary and generate output in `src/gen-erl`.  It will
also generate some Elixir wrappers in `lib/ex_gen`, but you won't be
using those.

If you're using Elixir, you can use `mix thrift` to generate the
Erlang files (generated by the thrift binary) and Elixir wrappers
(generated by ThriftEx).  Assuming your `.thrift` files are in the
`thrift` directory under your project's root directory, running
`mix thrift` will

1. Run the thrift binary with the Erlang generator (i.e.,
`thrift --gen erl`) and place generated output in `src/gen-erl`.
2. Compile the resulting Erlang code (the compiled modules are
needed for the next step).
3. Generate Elixir wrappers for constants defined in your
`.thrift` files and place the output in `lib/ex_gen`.
4. Generate Elixir wrappers for the types defined in your
`.thrift` files and place the output in `lib/ex_gen`.

The output of `mix thrift` should jive well with `mix compile`.  That
is, output files (both Erlang and Elixir) are placed in locations that
mix will automatically and appropriately compile when you run `mix
compile`.

Constants wrappers
------------------

If you have a constant `const i32 FOOBAR 42` defined in `foo.thrift`, the
thrift binary will generate `foo_constants.hrl` which defines
the constant as

```erlang
% foo_constants.hrl
-define(FOO_FOOBAR, 42).
```

This constant can be used at compile-time by the Erlang compiler, but that
doesn't really help us use it in Elixir.  Therefore, ThriftEx generates
`foo_constants.ex` which will contain

```elixir
# foo_constants.ex
defmodule FooConstants do
  # ... other constants from foo.thrift
  def foo_foobar do
    42
  end
  # ... other constants from foo.thrift
end
```

This allows us to access `FooConstants.foo_foobar` at runtime.

Records wrappers
----------------

The thrift binary converts `struct` definitions in your
`.thrift` files into `-record` definitions in `.hrl` files for
Erlang.  It also generates `struct_info` functions that return
metadata about the record (structure and type information).

ThriftEx generates record wrapper modules for each struct in your
`.thrift` files so that you can use them from Elixir code and iex in a
manner that is idiomatic.  It does this by inspecting the generated
`.hrl` and `.erl` files to extract the relevant definitions.

A struct in `foo.thrift` may look like

```thrift
// foo.thrift
struct Bar {
  1: i32 id = 0,
  2: optional string name
}
```

This will generate an Erlang record definition that looks like

```erlang
% foo_types.hrl
-record('Bar', {'id' = 0 :: integer(),
                'name' :: string() | binary()}).
```

It will also generate a `struct_info` function that looks like
```erlang
% foo_types.erl
struct_info('Bar') ->
  {struct, [{1, i32},
           {2, string}]}
;
```

From this, ThriftEx will generate a `bar.ex` module that looks like
```elixir
# bar.ex
defmodule Bar do
  require Record
  Record.defrecord :bar, :Bar,
    [id: 0, name: :undefined]

  def struct_info do
    {:struct, [{1, :i32}, {2, :string}]}
  end
end
```

Any instance of the `Bar` record should be equivalent in structure
and implementation to a corresponding `#'Bar'{}` instance in
erlang code.  Therefore, Elixir-generated records should be compatible
with any of the built-in thrift library function calls.

Note that records are implemented mainly using macros in Elixir, so
you will need to `require` the module to use it.

```
iex(1)> require Bar
nil
iex(2)> b = Bar.bar
{:Bar, 0, :undefined}
iex(3)> Bar.bar(b, :id)
0
```

TODO
----

1. Upload example (I have one that I have been working with, but it
isn't complete).
2. Helper methods to do typical operations (e.g., serialize/deserialize
to/from string or file) in Elixir.
3. Elixir helpers for client/server.

Philosophy
----------

The primary goals of the approach taken here are

1. Provide a way to include Apache Thrift in Erlang and Elixir
projects in a manner that is compatible with the mix build tool and
dependency management.
2. Allow for idiomatic usage in Elixir.
3. Do not unnecessarily reimplement anything in the underlying Thrift
   Erlang libraries.

Therefore, any knowledge you have on using the Erlang Thrift libraries
should apply here, and code implemented in this library is mainly
designed to get around idiomatic inconsistencies between Erlang and
Elixir and to provide helpers that compose functions from the Erlang
library.

Furthermore, the code and data generated in this library should
be completely compatible between Erlang and Elixir.
