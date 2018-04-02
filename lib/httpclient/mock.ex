defmodule Httpclient.Mock do

  @behaviour Httpclient.Behaviour

  @url "http://localhost:3000/"

  @first_post "{\"id\": 1, \"data\": \"test\", \"type\": \"post\"}"
  @updated_post "{\"id\": 1, \"data\": \"updated data\", \"type\": \"post\"}"
  @all_posts "[{\"id\": 1, \"data\": \"test\", \"type\": \"post\"}, {\"id\": 2, \"data\": \"test2\", \"type\": \"post\"}]"

  def send(%{method: "test", to: _to, body: _body, headers: _headers}) do
    %{"it" => "works"}
  end

  def send(%{method: :get, to: to, body: _body, headers: _headers}) do
    case to do
      @url <> "posts" ->
        {:ok, %{status_code: 200, body: @all_posts}}
      @url <> "posts/1" ->
        {:ok, %{status_code: 200, body: @first_post}}
    end
  end

  def send(%{method: :post, to: to, body: _body, headers: _headers}) do
    case to do
      @url <> "posts" ->
        {:ok, %{status_code: 201, body: @first_post}}
    end
  end

  def send(%{method: :put, to: to, body: _body, headers: _headers}) do
    case to do
      @url <> "posts/1" ->
        {:ok, %{status_code: 200, body: @updated_post}}
    end
  end
end
