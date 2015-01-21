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
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:thrift,
      git: "https://github.com/apache/thrift",
      tag: "0.9.2",
      app: false,
      compile: compile_thrift}]
  end


  def compile_thrift do
    thrift_lib_dir = Path.join([__DIR__, "deps", "thrift", "lib", "erl"])
    compile_cmd = "./rebar compile"
    ebin_dir = Path.join(thrift_lib_dir, "ebin")
    build_ebin_dir = Path.join([Mix.Project.build_path,
                                "lib", "thrift", "ebin"])
    IO.puts "BUILD PATH IS #{build_ebin_dir}"
    :ok = File.mkdir_p(build_ebin_dir)
    copy_beam_files = "cp #{ebin_dir}/* #{build_ebin_dir}/"
    
    "cd #{thrift_lib_dir} && #{compile_cmd} && #{copy_beam_files}"
  end
end
