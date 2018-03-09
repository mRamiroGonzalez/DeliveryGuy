defmodule DeliveryguyTest do
  use ExUnit.Case
  doctest Deliveryguy

  test "makes a request" do
    response = Deliveryguy.deliver_route("routes/create-event.json")
    assert response.status_code == 201
  end
end
