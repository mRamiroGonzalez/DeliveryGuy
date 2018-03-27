defmodule Dispatcher do

  use GenServer

  @m __MODULE__

  # INIT
  def start_link(state, opts) do
    GenServer.start_link(@m, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end


  # CLIENT
  def get_state(pid) do
    GenServer.call(pid, %{action: :get_state})
  end

  def add_global_entity(pid, name, entity) do
    GenServer.call(pid, %{action: :add, name: name, entity: entity})
  end

  def process_routes(pid, routes) do
    routes
      |> File.read!
      |> Poison.decode!
      |> Enum.reduce([], fn ({id, route}, acc) ->
          IO.puts("\nRoute: #{id}")
          codes =
            cond do
              Map.has_key?(route, "async") ->
                Log.info(@m, "Starting Async route: #{id}")
                deliver_route_async(route, pid)
              true ->
                Log.info(@m, "Starting Sync route: #{id}")
                deliver_route(route, pid)
              end
          [acc | codes]
        end)
      |> List.flatten
      |> Enum.all?(fn (x) -> x == :true end)
  end

  def deliver_route(route, dispatcherPid) do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    codes = Enum.reduce route["sync"], [], fn (houseInfos, acc) ->
      code = Deliveryguy.deliver_house(pid, houseInfos, dispatcherPid)
      [code | acc]
    end
    Enum.reverse(codes)
  end

  def deliver_route_async(route, dispatcherPid) do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    route["async"]
    |> Enum.map(&Task.async(fn -> Deliveryguy.deliver_house(pid, &1, dispatcherPid) end))
    |> Enum.map(&Task.await/1)
  end


  # SERVER
  def handle_call(%{action: :add, name: name, entity: entity}, _from, state) do
    Log.info(@m, "adding global entity: #{name}")
    Log.debug(@m, "global entity: #{inspect entity}")
    {:reply, :ok, Map.put(state, name, entity)}
  end

  def handle_call(%{action: :get_state}, _from, state) do
    {:reply, state, state}
  end
end