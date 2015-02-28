Mix.Task.run("thrift", ["--thrift-dir", "test/thrift", "--namespace", "thrift_ex_test"])
ExUnit.start()
