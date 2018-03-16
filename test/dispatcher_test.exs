defmodule DispatcherTest do
  use ExUnit.Case

  test "request_multiple" do
    filename = "test/routes/create-and-get-event.json"
    routesMap = filename |> File.read! |> Poison.decode!

    assert Dispatcher.deliver_route(routesMap)
  end

  test "request_post_multiple_async" do
    filename = "test/routes/create-two-events-async.json"
    routesMap = filename |> File.read! |> Poison.decode!

    assert Dispatcher.deliver_route_async(routesMap)
  end

  test "request_chain" do
    filename = "test/routes/multiple-steps-requests.json"
    assert not Dispatcher.process_routes(filename)
  end

  test "request_chain_value_replacement" do
    filename = "test/routes/get-create.json"
    routesMap = filename |> File.read! |> Poison.decode!

    assert Dispatcher.deliver_route(routesMap)
  end

  test "request_chain_value_field_replacement" do
    filename = "test/routes/get-create-save-field.json"
    routesMap = filename |> File.read! |> Poison.decode!

    assert Dispatcher.deliver_route(routesMap)
  end
end
