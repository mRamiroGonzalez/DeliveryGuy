defmodule DispatcherTest do
  use ExUnit.Case

  test "request_multiple" do
    filename = "test/routes/create-and-get-event.json"
    routesMap = filename |> File.read! |> Poison.decode!

    codes = Dispatcher.deliver_route(routesMap)

    assert codes == [201, 200]
  end

  test "request_post_multiple_async" do
    filename = "test/routes/create-two-events-async.json"
    routesMap = filename |> File.read! |> Poison.decode!

    codes = Dispatcher.deliver_route_async(routesMap)

    assert codes == [201, 201]
  end

  test "request_chain" do
    filename = "test/routes/multiple-steps-requests.json"
    codes = Dispatcher.process_routes(filename)

    assert codes == [404, 201, 200, 201, 201, 201, 201]
  end

  test "request chain with whole value interpolation" do
    filename = "test/routes/get-create.json"
    routesMap = filename |> File.read! |> Poison.decode!

    codes = Dispatcher.deliver_route(routesMap)

    assert codes == [200, 200]
  end

  test "request chain with value field interpolation" do
    filename = "test/routes/get-create-save-field.json"
    routesMap = filename |> File.read! |> Poison.decode!

    codes = Dispatcher.deliver_route(routesMap)

    assert codes == [200, 200, 200]
  end

end
