defmodule Httpclient.Mock do

  @behaviour Httpclient.Behaviour
  @url "http://localhost:3000/"

  @all_events "[{\"id\": 1, \"data\": \"test\"}, {\"id\": 2, \"data\": \"test2\"}]"

  def send(%{method: "test", to: _to, body: _body, headers: _headers}) do
    %{"it" => "works"}
  end

  def send(%{method: :get, to: to, body: _body, headers: _headers}) do
    case to do
      @url <> "posts" ->
        response = %{status_code: 200, body: @all_events}
        {:ok, response}
    end
  end

  def send(%{method: :post, to: to, body: _body, headers: _headers}) do
    case to do
      @url <> "posts" ->
        response = %{status_code: 201, body: "{}"}
        {:ok, response}
    end
  end
end
