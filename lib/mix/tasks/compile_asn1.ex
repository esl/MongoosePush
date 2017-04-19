defmodule Mix.Tasks.Compile.Asn1 do
  @moduledoc """
  This task compiles all ASN.1 files (in `asn1/*.asn`) into erlang sources into `src` directory.
  After that Erlang compiler (task Compile.Erlang) shall be run to compile them into .beam binaries.
  """
  @shortdoc "Compiles ASN.1 files to Erlang sources"

  use Mix.Task

  @asn1_src "asn.1"
  @erl_src "src"

  @spec run(term) :: :ok
  def run(_) do
    File.mkdir_p!(@erl_src)
    for file <- ls_r!(@asn1_src) do
      case Path.extname(file) do
        ".asn" ->
          asn = Path.basename(file)
          :asn1ct.compile(to_charlist(asn),
                          [:noobj, i: to_charlist(@asn1_src), outdir: to_charlist(@erl_src)])
        _ -> :skip
      end
    end
  end

  def ls_r!(path \\ ".") do
    cond do
      File.regular?(path) -> [path]
      File.dir?(path) ->
        File.ls!(path)
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(&ls_r!/1)
        |> Enum.concat
      true -> []
    end
  end
end
