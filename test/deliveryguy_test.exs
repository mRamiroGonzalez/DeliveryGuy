defmodule DeliveryguyTest do
  use ExUnit.Case
  doctest Deliveryguy

  test "makes a request" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    Deliveryguy.deliver_route(pid, "lib/routes/create-event.json")
    state = Deliveryguy.get_state(pid)

    assert state["event"]["id"] != nil
  end
end
