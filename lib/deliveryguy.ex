defmodule Deliveryguy do

  use GenServer

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def deliver_route(pid, route) do
    routeMap = Poison.decode! File.read! route
    Enum.reduce routeMap, [], fn ({_id, houseInfos}, acc) ->
      code = deliver_house(pid, houseInfos)
      [code | acc]
    end
  end

  def deliver_house(pid, houseInfos) do
    packageName = houseInfos["response"]["entityName"]

    response = GenServer.call(pid, houseInfos)
    responsePackage = Poison.decode! response.body
    add_entity(pid, packageName, responsePackage)

    response.status_code
  end

  def add_entity(pid, name, entity) do
    GenServer.call(pid, %{action: :add, name: name, entity: entity})
  end

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end



  def handle_call(%{action: :add, name: name, entity: entity}, _from, state) do
    {:reply, :ok, Map.put(state, name, entity)}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(houseInfos, _from, state) do
    to = houseInfos["request"]["to"]
    body = Poison.encode! houseInfos["request"]["body"]
    headers = houseInfos["request"]["headers"]

    response = HTTPoison.post! to, body, headers

    {:reply, response, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

end