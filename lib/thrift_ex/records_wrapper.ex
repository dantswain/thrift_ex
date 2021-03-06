defmodule ThriftEx.RecordsWrapper do
  def generate(hrl, out_dir, namespace) do
    IO.puts hrl
    find_records(hrl)
    |> Enum.map(fn(r) ->
                  %{orig_name: r,
                    module_name: module_name(namespace, r),
                    defn: extract_record(r, hrl),
                    struct_info: extract_struct_info(r, hrl)
                   }
                end)
    |> Enum.map(fn(recd) ->
                  contents = gen_file(hrl, recd)
                  write_file(recd, contents, out_dir)
                end)
  end

  defp write_file(recd, contents, out_dir) do
    fname = Mix.Utils.underscore(recd[:module_name])
    path = Path.join(out_dir, fname <> ".ex")
    path |> Path.dirname |> File.mkdir_p
    File.write(path, contents)
  end

  defp gen_file(hrl, recd) do
    record_name = String.to_atom(Mix.Utils.underscore(recd[:orig_name]))
    record_tag = String.to_atom(recd[:orig_name])
    [
        "defmodule #{recd[:module_name]} do",
        "  # GENERATED by ThriftEx from #{hrl}",
        "",
        "  require Record",
        "  Record.defrecord #{inspect record_name}, #{inspect record_tag}, ",
        "      #{inspect recd[:defn]}",
        "",
        "  def record_tag do",
        "    #{inspect record_tag}",
        "  end",
        "",
        "  def struct_info do",
        "    #{inspect recd[:struct_info]}",
        "  end",
        "end",
        ""
    ] |> Enum.join("\n")
  end

  defp extract_record(r, hrl) do
    Record.Extractor.extract(String.to_atom(r), from: hrl)
  end

  defp extract_struct_info(r, hrl) do
    m = Path.basename(hrl, ".hrl") |> String.to_atom
    m.struct_info(r |> String.to_atom)
  end

  defp find_records(hrl) do
    {:ok, contents} = File.read(hrl)
    contents
    |> String.split("\n")
    |> Enum.filter(&line_defines_record?/1)
    |> Enum.map(&record_name_from_line/1)
  end

  defp line_defines_record?(line) do
    String.match?(line, ~r/^-record/)
  end

  defp module_name(nil, name) do
    Mix.Utils.command_to_module_name(name)
  end

  defp module_name(namespace, name) do
    Mix.Utils.command_to_module_name(namespace) <> "." <>
      Mix.Utils.command_to_module_name(name)
  end

  defp record_name_from_line(line) do
    Regex.named_captures(~r/^-record\((?<name>[^,]+), /,
                         line)["name"]
    |> String.strip(?')
  end
end
