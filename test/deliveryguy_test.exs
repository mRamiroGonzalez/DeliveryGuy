defmodule DeliveryguyTest do
  use ExUnit.Case

  @testFilesPath "test/routes/deliveryGuy/"

  @tag :wip
  test "it uses mock in tests" do
    result = Httpclient.send(%{method: "test", to: "", body: "", headers: ""})
    assert result["it"] == "works"
  end

  test "request_post" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])
    {:ok, dispatcherPid} = GenServer.start_link(Dispatcher, [])

    filename = @testFilesPath <> "request-post.json"

    routeInfos = Poison.decode! File.read! filename
    houseInfos = List.first routeInfos["sync"]
    responseType = houseInfos["response"]["entityName"]

    success = Deliveryguy.make_request(pid, houseInfos, dispatcherPid)
    state = Deliveryguy.get_state(pid)

    assert state[responseType] != nil
    assert success
  end

  test "request_get" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])
    {:ok, dispatcherPid} = GenServer.start_link(Dispatcher, [])

    filename = @testFilesPath <> "request-get.json"

    routeInfos = Poison.decode! File.read! filename
    houseInfos = List.first routeInfos["sync"]
    responseType = List.first(routeInfos["sync"])["response"]["entityName"]

    success = Deliveryguy.make_request(pid, houseInfos, dispatcherPid)
    state = Deliveryguy.get_state(pid)

    assert success
    assert length(state[responseType]) > 0
  end

  test "add_entity" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])

    entity = %{"aze": 1}
    Deliveryguy.add_entity(pid, "test", entity)
    state = Deliveryguy.get_state(pid)

    assert state["test"] == entity
  end

  test "request_fail" do
    {:ok, pid} = GenServer.start_link(Deliveryguy, [])
    {:ok, dispatcherPid} = GenServer.start_link(Dispatcher, [])

    filename = @testFilesPath <> "request-fail.json"

    routeInfos = Poison.decode! File.read! filename
    houseInfos = List.first routeInfos["sync"]

    success = Deliveryguy.make_request(pid, houseInfos, dispatcherPid)
    state = Deliveryguy.get_state(pid)

    assert state == %{}
    assert not success
  end
end
