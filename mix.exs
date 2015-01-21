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
    env = Atom.to_string(Mix.env)

    build_ebin_dir = Path.join(["..", "..", "..", "..", "_build", env,
                                "lib", "thrift", "ebin"])
    IO.puts "BUILD PATH IS #{build_ebin_dir}"
    IO.puts "CWD IS #{System.cwd}"

    IO.puts "HI #{inspect build_ebin_dir}"

    cmd = "cd lib/erl && ./rebar compile && mkdir -p #{build_ebin_dir} && ls -lah #{build_ebin_dir} && cp ebin/* #{build_ebin_dir}/"
    IO.puts cmd
    cmd
  end
end
