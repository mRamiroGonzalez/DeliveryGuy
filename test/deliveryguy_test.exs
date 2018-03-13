defmodule DeliveryguyTest do
  use ExUnit.Case
  doctest Deliveryguy

  setup_all do
    # > json-server --watch db.json
    filename = "test/db.json"
    emptydb = "{\"events\": [
                  {
                    \"type\": \"FIRST_EVENT\",
                    \"startDate\": \"2030-01-01T01:00Z[UTC]\",
                    \"endDate\": \"2030-01-01T03:00Z[UTC]\",
                    \"id\": 1
                  }
              ]}"
    {:ok, file} = File.open(filename, [:write])
    IO.write(file, emptydb)
    File.close(file)
  end

  test "make a POST request" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])
    filename = "test/routes/create-event.json"

    routeInfos = Poison.decode! File.read! filename
    houseInfos = List.first routeInfos["sync"]
    responseType = houseInfos["response"]["entityName"]

    responseCode = Deliveryguy.deliver_house(pid, houseInfos)
    state = Deliveryguy.get_state(pid)

    assert state[responseType] != nil
    assert responseCode == 201
  end

  test "make multiple POST requests" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])
    filename = "test/routes/create-two-events.json"

    codes = Deliveryguy.deliver_route(pid, filename)
    state = Deliveryguy.get_state(pid)
    stateList = Enum.to_list(state)

    assert codes == [201, 201]
    assert length(stateList) == 2
  end

  test "make multiple POST request async" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])
    filename = "test/routes/create-two-events-async.json"

    codes = Deliveryguy.deliver_route_async(pid, filename)
    state = Deliveryguy.get_state(pid)
    stateList = Enum.to_list(state)

    assert codes == [201, 201]
    assert length(stateList) == 2
  end

  test "make a GET request" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])
    filename = "test/routes/get-all-events.json"

    routeInfos = Poison.decode! File.read! filename
    responseType = List.first(routeInfos["sync"])["response"]["entityName"]

    codes = Deliveryguy.deliver_route(pid, filename)
    state = Deliveryguy.get_state(pid)

    assert codes == [200]
    assert length(state[responseType]) > 0
  end

  test "adds an entity" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    entity = %{"aze": 1}
    Deliveryguy.add_entity(pid, "test", entity)
    state = Deliveryguy.get_state(pid)

    assert state["test"] == entity
  end

  test "adds globals variables to a runner" do
    {:ok, globalsPid} = GenServer.start_link(Globals, [])
    {:ok, deliveryPid} = GenServer.start_link(Deliveryguy, [])

    key = "key"
    value = "value"

    Deliveryguy.add_entity(deliveryPid, "globalsPid", globalsPid)
    Globals.add_value(globalsPid, key, value)
    globals = Deliveryguy.get_globals(deliveryPid)

    assert globals[key] == value
  end

  test "matches the return value with the expectation" do
    {:ok, _pid} = GenServer.start_link(Deliveryguy, [])
    filename = "test/routes/create-event.json"

    routeInfos = Poison.decode! File.read! filename
    houseInfos = List.first routeInfos["sync"]

    response = Map.put(%{}, :status_code, 201)
    result = Deliveryguy.validateResponse(houseInfos, response)

    assert result == true
  end

  test "does not save the entity because the validation is not ok" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])
    filename = "test/routes/create-event-fail.json"

    Deliveryguy.deliver_route(pid, filename)
    state = Deliveryguy.get_state(pid)

    assert state == %{}
  end
end
