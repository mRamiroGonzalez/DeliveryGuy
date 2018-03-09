defmodule Deliveryguy do

  def deliver_route(route) do
    route = Poison.decode! File.read! route

    to = route["request"]["to"]
    body = Poison.encode! route["request"]["body"]
    headers = route["request"]["headers"]

    HTTPoison.post! to, body, headers
  end
end