defmodule ThriftEx do
  #@temp_directory Path.join([__DIR__, "..", "TEMP"])
  #@git_repo "https://github.com/apache/thrift"

  #:ok = File.mkdir_p(@temp_directory)
  #Mix.SCM.Git.checkout(%{path: @temp_directory, git: @git_repo})
  def hi do
    IO.puts "FUCK YOU"
  end
end
