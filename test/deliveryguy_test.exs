defmodule DeliveryguyTest do
  use ExUnit.Case
  doctest Deliveryguy

  test "delivers a house" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    routeInfos = Poison.decode! File.read! "test/routes/create-event.json"
    houseInfos = routeInfos["1"]
    responseCode = Deliveryguy.deliver_house(pid, houseInfos)
    state = Deliveryguy.get_state(pid)

    assert state["event"]["id"] != nil
    assert responseCode == 201
  end

  test "delivers multiple houses" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])
    codes = Deliveryguy.deliver_route(pid, "test/routes/create-two-events.json")
    assert codes == [201, 201]
  end
end
