defmodule GlobalsTest do
  use ExUnit.Case

  test "add global variables" do
    {:ok, pid} = GenServer.start_link(Globals, [])

    key = "var"
    value = "test"
    key2 = "var2"
    value2 = "test2"

    Globals.add_value(pid, key, value)
    Globals.add_value(pid, key2, value2)

    state = Globals.get_state(pid)

    assert state[key] == value
    assert state[key2] == value2
    assert state[key] != state[key2]
  end
end
