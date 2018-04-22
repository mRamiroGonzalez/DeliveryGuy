defmodule DispatcherTest do
  use ExUnit.Case

  @testFilesPath "test/routes/dispatcher/"

  test "multipleRequests_sync" do
    filename = @testFilesPath <> "multipleRequests-sync.json"
    routesMap = filename |> File.read! |> Poison.decode!

    {:ok, pid} = GenServer.start_link(Dispatcher, [])

    assert Dispatcher.deliver_route(routesMap, pid)
  end

  test "multipleRequests_async" do
    filename = @testFilesPath <> "multipleRequests-async.json"
    routesMap = filename |> File.read! |> Poison.decode!

    {:ok, pid} = GenServer.start_link(Dispatcher, [])

    assert Dispatcher.deliver_route_async(routesMap, pid)
  end

  test "multipleRequests_multipleRoutes" do
    filename = @testFilesPath <> "multipleRequests-multipleRoutes.json"

    {:ok, pid} = GenServer.start_link(Dispatcher, [])

    assert Dispatcher.process_routes(pid, filename)
  end

  test "multipleRequests_replaceBody" do
    filename = @testFilesPath <> "multipleRequests-replaceBody.json"
    routesMap = filename |> File.read! |> Poison.decode!

    {:ok, pid} = GenServer.start_link(Dispatcher, [])

    assert Dispatcher.deliver_route(routesMap, pid)
  end

  test "multipleRequests_replaceValues" do
    filename = @testFilesPath <> "multipleRequests-replaceValues.json"
    routesMap = filename |> File.read! |> Poison.decode!

    {:ok, pid} = GenServer.start_link(Dispatcher, [])

    assert Dispatcher.deliver_route(routesMap, pid)
  end

  test "multipleRequests_multipleRoutes_replaceValues_fromGlobals" do
    filename = @testFilesPath <> "multipleRequests-multipleRoutes-replaceValues-fromGlobals.json"

    {:ok, pid} = GenServer.start_link(Dispatcher, [])

    assert Dispatcher.process_routes(pid, filename)
  end
end
