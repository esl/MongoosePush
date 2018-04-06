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
    :ok = File.mkdir_p!(@erl_src)
    to_compile = Path.join(@asn1_src, "**/*.asn")
    result =
      for file <- Path.wildcard(to_compile) do
        asn = Path.basename(file)
        :asn1ct.compile(to_charlist(asn),
                        [:noobj, i: to_charlist(@asn1_src), outdir: to_charlist(@erl_src)])
      end

    case Enum.filter(result, &(&1 != :ok)) do
      [] ->
        :ok
      Errors ->
        {:error, Errors}
    end
  end

end
