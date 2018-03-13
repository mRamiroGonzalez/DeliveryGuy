defmodule DispatcherTest do
  use ExUnit.Case

  test "make multiple POST requests" do
    filename = "test/routes/create-two-events.json"
    codes = Dispatcher.deliver_route(filename)

    assert codes == [201, 201]
  end

  test "make multiple POST request async" do
    filename = "test/routes/create-two-events-async.json"
    codes = Dispatcher.deliver_route_async(filename)

    assert codes == [201, 201]
  end

end
