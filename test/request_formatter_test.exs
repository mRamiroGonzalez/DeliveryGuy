defmodule RequestFormatterTest do
  use ExUnit.Case

  test "replaceDataInMap_success" do
    url = "http://localhost:{{port}}/events/{{event.id}}"
    dataMap = %{"event" => %{"id" => 5}, "port" => 3000}

    assert RequestFormatter.replace_values_in_map(url, dataMap) == "http://localhost:3000/events/5"
  end

  test "replaceDataInMap_wrongKey" do
    url = "http://localhost:{{prt}}/events/{{event.id}}"
    dataMap = %{"event" => %{"id" => 5}, "port" => 3000}

    assert RequestFormatter.replace_values_in_map(url, dataMap) == "http://localhost:{{prt}}/events/5"
  end

  test "replaceDataInMap_valueNotPresent" do
    url = "http://localhost:{{port}}/events/{{event.id}}"
    dataMap = %{"event" => %{"id" => 5}}

    assert RequestFormatter.replace_values_in_map(url, dataMap) == "http://localhost:{{port}}/events/5"
  end

  test "replaceDataInMap_wrongFormat" do
    url = "http://localhost:{{port}}/events/{{event-id}}"
    dataMap = %{"event" => %{"id" => 5}, "port" => 3000}

    assert RequestFormatter.replace_values_in_map(url, dataMap) == "http://localhost:3000/events/{{event-id}}"
  end
end