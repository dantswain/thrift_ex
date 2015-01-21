defmodule Mix.Tasks.Thrift do
  use Mix.Task

  def run(args) do
    options = parse_options(args)
    File.mkdir_p!(options[:o_dir])
    run_thrift(options[:thrift_dir], options[:o_dir])
  end

  defp parse_options(args) do
    {switches,
     _argv,
     _errors} = OptionParser.parse(args)

    thrift_dir = case switches[:thrift_dir] do
                   nil -> "thrift";
                   dir -> dir
                 end
    o_dir = case switches[:o] do
                nil -> "src";
                dir -> dir
              end

    %{thrift_dir: thrift_dir, o_dir: o_dir}
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
end

defmodule ThriftEx.Mixfile do
  use Mix.Project

  def project do
    [app: :thrift_ex,
     version: "0.0.1",
     elixir: "~> 1.1-dev",
     thrift_dep_dir: Mix.Project.deps_path, 
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:thrift,
      git: "https://github.com/apache/thrift",
      tag: "0.9.2",
      app: false,
      compile: compile_thrift}]
  end


  def compile_thrift do

    ## HERE is where the problem is
    ##  In a project that uses this project as a dependency, thrift gets
    ##  cloned into _that_ project's deps directories, so I need to be
    ##  able to get into that directory.
    deps_dir = Mix.Project.deps_path
    IO.puts "DEPS DIR IS #{inspect deps_dir}"
    IO.puts "PROJECT CONFIG IS #{inspect Mix.Project.config}"

    thrift_lib_dir = Path.join([deps_dir, "thrift", "lib", "erl"])
    compile_cmd = "./rebar compile"
    ebin_dir = Path.join(thrift_lib_dir, "ebin")

    ## ALSO HERE I need to be able to put the compiled .beam files
    ## somewhere that the child project will load them
    build_ebin_dir = Path.join([Mix.Project.build_path,
                                "lib", "thrift", "ebin"])
    IO.puts "BUILD PATH IS #{build_ebin_dir}"

    :ok = File.mkdir_p(build_ebin_dir)
    copy_beam_files = "cp #{ebin_dir}/* #{build_ebin_dir}/"
    
    "cd #{thrift_lib_dir} && #{compile_cmd} && #{copy_beam_files}"
  end
end
