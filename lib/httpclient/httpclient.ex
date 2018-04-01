defmodule Httpclient do
  @httpclient_impl Application.fetch_env!(:deliveryguy, :httpclient)

  defmodule Behaviour do
    @callback send(Map) :: Map
  end

  def send(request) do
    @httpclient_impl.send(request)
  end
end
