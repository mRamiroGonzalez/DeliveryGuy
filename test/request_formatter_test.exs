defmodule RequestFormatterTest do
  use ExUnit.Case

  test "replace_data_in_map" do
    url = "http://localhost:{{port}}/events/{{event.id}}"
    dataMap = %{"event" => %{"id" => 5}, "port" => 3000}

    assert RequestFormatter.replace_values_in_map(url, dataMap) == "http://localhost:3000/events/5"
  end
end