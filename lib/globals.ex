defmodule Globals do

  use GenServer

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def add_value(pid, key, value) do
    GenServer.call(pid, %{action: :add, key: key, value: value})
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def init(_opts) do
    {:ok, %{}}
  end



  def handle_call(%{action: :add, key: key, value: value}, _from, state) do
    {:reply, :ok, Map.put(state, key, value)}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end