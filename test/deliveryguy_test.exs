defmodule DeliveryguyTest do
  use ExUnit.Case
  doctest Deliveryguy

  test "delivers a house" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    routeInfos = Poison.decode! File.read! "test/routes/create-event.json"
    houseInfos = routeInfos["1"]
    responseCode = Deliveryguy.deliver_house(pid, houseInfos)
    state = Deliveryguy.get_state(pid)

    assert state["event_1"]["id"] != nil
    assert responseCode == 201
  end

  test "delivers multiple houses" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    codes = Deliveryguy.deliver_route(pid, "test/routes/create-two-events.json")
    state = Deliveryguy.get_state(pid)
    stateList = Enum.to_list(state)
    IO.inspect stateList

    assert codes == [201, 201]
    assert length(stateList) == 2
  end

  test "adds an entity" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    entity = %{"aze": 1}
    Deliveryguy.add_entity(pid, "test", entity)
    state = Deliveryguy.get_state(pid)

    assert state["test"] == entity
  end
end
