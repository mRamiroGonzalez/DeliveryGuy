defmodule Httpclient.Httpoison do

  @behaviour Httpclient.Behaviour

  def send(%{method: method, to: to, body: body, headers: headers}) do
    HTTPoison.request(method, to, body, headers)
  end
end
