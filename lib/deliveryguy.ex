defmodule Deliveryguy do

  use GenServer

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def deliver_route(pid, route) do
    routeMap = Poison.decode! File.read! route
    GenServer.call(pid, routeMap)
  end

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(route, _from, state) do
    to = route["request"]["to"]
    body = Poison.encode! route["request"]["body"]
    headers = route["request"]["headers"]

    response = HTTPoison.post! to, body, headers

    packageName = route["response"]["package"]
    packagePath = "lib/packages/" <> packageName <> ".json"
    package = Poison.decode! File.read! packagePath
    responsePackage = Poison.decode! response.body

    state = Map.put(state, packageName, Map.merge(package, responsePackage))
    {:reply, response.status_code, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

end