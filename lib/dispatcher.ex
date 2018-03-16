defmodule Dispatcher do

  @m __MODULE__

  def main(args \\ []) do
    args                    # mix escript.build
    |> parse_args           # ./deliveryguy --source "test/routes/multiple-steps-requests.json"
    |> response
    |> IO.puts()
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
        opts[:source] -> process_routes(opts[:source])
        true -> "Command not supported"
      end
    if (result), do: 1, else: 0
  end

  def process_routes(routes) do
    routes
      |> File.read!
      |> Poison.decode!
      |> Enum.reduce([], fn ({id, route}, acc) ->
          codes =
            cond do
              Map.has_key?(route, "async") ->
                Log.info(@m, "Starting Async route: #{id}")
                deliver_route_async(route)
              true ->
                Log.info(@m, "Starting Sync route: #{id}")
                deliver_route(route)
              end
          [acc | codes]
        end)
      |> List.flatten
      |> Enum.all?(fn (x) -> x == :true end)
  end

  def deliver_route(route) do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    codes = Enum.reduce route["sync"], [], fn (houseInfos, acc) ->
      code = Deliveryguy.deliver_house(pid, houseInfos)
      [code | acc]
    end
    Enum.reverse(codes)
  end

  def deliver_route_async(route) do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    route["async"]
    |> Enum.map(&Task.async(fn -> Deliveryguy.deliver_house(pid, &1) end))
    |> Enum.map(&Task.await/1)
  end
end