defmodule Httpclient do
  @httpclient_impl Application.fetch_env!(:deliveryguy, :httpclient)

  # https://medium.com/@lasseebert/mocks-in-elixir-7204f8cc9d0f

  defmodule Behaviour do
    @callback send(Map) :: Map
  end

  def send(request) do
    @httpclient_impl.send(request)
  end
end
