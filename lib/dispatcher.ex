defmodule Dispatcher do

  def process_routes(routes) do
    routes
      |> File.read!
      |> Poison.decode!
      |> Enum.reduce([], fn ({_id, route}, acc) ->
          codes =
            cond do
              Map.has_key?(route, "async") ->
                deliver_route_async(route)
              true ->
                deliver_route(route)
              end
          [acc | codes]
        end)
      |> List.flatten
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