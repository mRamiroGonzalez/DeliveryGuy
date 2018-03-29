defmodule ArgsParser do

  def main(args \\ []) do
    exitCode =
      args                    # mix escript.build
      |> parse_args           # ./deliveryguy --source "test/routes/multiple-steps-requests.json"
      |> response
    IO.puts(exitCode)
    exitCode
  end

  defp parse_args(args) do
    {opts, word, _} =
      args
      |> OptionParser.parse(switches: [source: :string])

    {opts, List.to_string(word)}
  end

  defp response({opts, _word}) do
    result =
      cond do
        opts[:source] ->
          {:ok, pid} = GenServer.start_link(Dispatcher, [])
          Dispatcher.process_routes(pid, opts[:source])
        true ->
          IO.puts "Command not supported"
          :false
      end
    if (result), do: 1, else: 0
  end

end
