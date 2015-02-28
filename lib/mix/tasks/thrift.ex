defmodule Mix.Tasks.Thrift do
  use Mix.Task

  def run(args) do
    options = parse_options(args)
    File.mkdir_p!(options[:o_dir])
    run_thrift(options[:thrift_dir], options[:o_dir])

    compile_thrift_erl

    generate_constants_wrappers(options[:o_dir], options[:namespace])
    generate_records_wrappers(options[:o_dir], options[:namespace])
  end

  defp parse_options(args) do
    {switches,
     _argv,
     _errors} = OptionParser.parse(args)

    namespace = switches[:namespace]

    thrift_dir = case switches[:thrift_dir] do
                   nil -> "thrift";
                   dir -> dir
                 end
    o_dir = case switches[:o] do
                nil -> "src";
                dir -> dir
              end

    %{thrift_dir: thrift_dir, o_dir: o_dir, namespace: namespace}
  end

  defp run_thrift(thrift_dir, o_dir) do
    thrift_files(thrift_dir)
    |> Enum.each(fn(f) -> run_thrift_on(f, o_dir) end)
  end

  defp thrift_files(thrift_dir) do
    Mix.Utils.extract_files([thrift_dir], "*.thrift")
  end

  defp run_thrift_on(f, o_dir) do
    cmd = "thrift -o #{o_dir} --gen erl #{f}"
    IO.puts cmd
    0 = Mix.shell.cmd(cmd)
  end

  defp generate_constants_wrappers(o_dir, namespace) do
    gen_dir = Path.join([System.cwd, "lib", "ex_gen"])
    constant_files(o_dir)
    |> Enum.each(fn(hrl) ->
                   generate_constants_wrapper(hrl, gen_dir, namespace)
                 end)
  end

  defp generate_constants_wrapper(hrl, gen_dir, namespace) do
    ThriftEx.ConstantsWrapper.generate(hrl, gen_dir, namespace)
  end

  defp constant_files(o_dir) do
    Mix.Utils.extract_files([o_dir], "*_constants.hrl")
  end

  defp generate_records_wrappers(o_dir, namespace) do
    gen_dir = Path.join([System.cwd, "lib", "ex_gen"])
    records_files(o_dir)
    |> Enum.each(fn(hrl) ->
                   generate_records_wrapper(hrl, gen_dir, namespace)
                 end)
  end

  defp generate_records_wrapper(hrl, gen_dir, namespace) do
    ThriftEx.RecordsWrapper.generate(hrl, gen_dir, namespace)
  end

  defp records_files(o_dir) do
    Mix.Utils.extract_files([o_dir], "*_types.hrl")
  end

  defp compile_thrift_erl do
    Mix.Task.reenable("compile.erlang")
    Mix.Task.run("compile.erlang")
  end
end
