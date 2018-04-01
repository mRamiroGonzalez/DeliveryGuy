defmodule Httpclient.Mock do

  @behaviour Httpclient.Behaviour

  def send(%{method: "test", to: _to, body: _body, headers: _headers}) do
    %{"it" => "works"}
  end
end
