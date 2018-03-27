defmodule DispatcherTest do
  use ExUnit.Case

  test "request_multiple" do
    filename = "test/routes/create-and-get-event.json"
    routesMap = filename |> File.read! |> Poison.decode!

    {:ok, pid} = GenServer.start_link(Dispatcher, [])

    assert Dispatcher.deliver_route(routesMap, pid)
  end

  test "request_post_multiple_async" do
    filename = "test/routes/create-two-events-async.json"
    routesMap = filename |> File.read! |> Poison.decode!

    {:ok, pid} = GenServer.start_link(Dispatcher, [])

    assert Dispatcher.deliver_route_async(routesMap, pid)
  end

  test "request_chain" do
    filename = "test/routes/multiple-steps-requests.json"

    {:ok, pid} = GenServer.start_link(Dispatcher, [])

    assert not Dispatcher.process_routes(pid, filename)
  end

  test "request_chain_value_replacement" do
    filename = "test/routes/get-create.json"
    routesMap = filename |> File.read! |> Poison.decode!

    {:ok, pid} = GenServer.start_link(Dispatcher, [])

    assert Dispatcher.deliver_route(routesMap, pid)
  end

  test "request_chain_value_field_replacement" do
    filename = "test/routes/get-update.json"
    routesMap = filename |> File.read! |> Poison.decode!

    {:ok, pid} = GenServer.start_link(Dispatcher, [])

    assert Dispatcher.deliver_route(routesMap, pid)
  end

  test "request_chain_value_field_replacement_multiple_routes" do
    filename = "test/routes/get-update-globals.json"

    {:ok, pid} = GenServer.start_link(Dispatcher, [])

    assert Dispatcher.process_routes(pid, filename)
  end
end
