defmodule Dispatcher do

  def deliver_route(route) do
    routeMap = Poison.decode! File.read! route
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    Enum.reduce routeMap["sync"], [], fn (houseInfos, acc) ->
      code = Deliveryguy.deliver_house(pid, houseInfos)
      [code | acc]
    end
  end

  def deliver_route_async(route) do
    routeMap = Poison.decode! File.read! route
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    routeMap["async"]
    |> Enum.map(&Task.async(fn -> Deliveryguy.deliver_house(pid, &1) end))
    |> Enum.map(&Task.await/1)
  end
end