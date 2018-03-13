defmodule DispatcherTest do
  use ExUnit.Case

  test "request_post_multiple" do
    filename = "test/routes/create-two-events.json"
    codes = Dispatcher.deliver_route(filename)

    assert codes == [201, 201]
  end

  test "request_post_multiple_async" do
    filename = "test/routes/create-two-events-async.json"
    codes = Dispatcher.deliver_route_async(filename)

    assert codes == [201, 201]
  end

end
