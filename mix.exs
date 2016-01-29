defmodule ThriftEx.Mixfile do
  use Mix.Project

  def project do
    [app: :thrift_ex,
     version: "0.0.1",
     elixir: "~> 1.0",
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
      compile: compile_thrift},
     {:quaff, github: "qhool/quaff"}]
  end


  def compile_thrift do
    [
        # some shells put utf chars in this variable, which can
        # throw off rebar
        "unset vcs_info_msg_0_",
        "cd lib/erl",
        "./rebar compile",
        "rm -rf ../../ebin",
        "mv ebin ../../ebin",
        "cp -R include ../../"
    ] |> Enum.join(" && ")
  end
end
