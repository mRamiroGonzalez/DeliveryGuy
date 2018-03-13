defmodule DeliveryguyTest do
  use ExUnit.Case
  doctest Deliveryguy

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

  test "make a GET request" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])
    filename = "test/routes/get-all-events.json"

    routeInfos = Poison.decode! File.read! filename
    houseInfos = List.first routeInfos["sync"]
    responseType = List.first(routeInfos["sync"])["response"]["entityName"]

    statusCode = Deliveryguy.deliver_house(pid, houseInfos)
    state = Deliveryguy.get_state(pid)

    assert statusCode == 200
    assert length(state[responseType]) > 0
  end

  test "adds an entity to the state" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    entity = %{"aze": 1}
    Deliveryguy.add_entity(pid, "test", entity)
    state = Deliveryguy.get_state(pid)

    assert state["test"] == entity
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

    routeInfos = Poison.decode! File.read! filename
    houseInfos = List.first routeInfos["sync"]

    Deliveryguy.deliver_house(pid, houseInfos)
    state = Deliveryguy.get_state(pid)

    assert state == %{}
  end
end
