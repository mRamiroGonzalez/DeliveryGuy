defmodule Deliveryguy do

  use GenServer

  @m __MODULE__

  # CLIENT
  def get_state(pid) do
    GenServer.call(pid, %{action: :get_state})
  end

  def deliver_house(pid, houseInfos, dispatcherPid) do
    Log.debug(@m, "local state: #{inspect get_state(pid)}")
    Log.debug(@m, "global state: #{inspect Dispatcher.get_state(dispatcherPid)}")

    Log.info(@m, "Updating values with global variables")
    houseInfos = RequestFormatter.replace_values_in_map(houseInfos, Dispatcher.get_state(dispatcherPid))

    Log.info(@m, "Updating values with route variables")
    houseInfos = RequestFormatter.replace_values_in_map(houseInfos, get_state(pid))

    response = GenServer.call(pid, houseInfos)
    responseBody = case response do
      {:error, _reason} -> nil
      response -> Poison.decode! response.body
    end

    if(Validator.validateStatusCode(houseInfos, response)) do
      entityName = houseInfos["response"]["entityName"]
      entityType = houseInfos["response"]["type"]
      if(entityName != nil) do
        if(entityType == "global") do
          Dispatcher.add_global_entity(dispatcherPid, entityName, responseBody)
        else
          add_entity(pid, entityName, responseBody)
        end
      end
      :true
    else
      :false
    end
  end

  def add_entity(pid, name, entity) do
    GenServer.call(pid, %{action: :add, name: name, entity: entity})
  end


  # INIT
  def start_link(state, opts) do
    GenServer.start_link(@m, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end


  # SERVER
  def handle_call(%{action: :add, name: name, entity: entity}, _from, state) do
    Log.info(@m, "adding entity: #{name}")
    Log.debug(@m, "entity: #{inspect entity}")
    {:reply, :ok, Map.put(state, name, entity)}
  end

  def handle_call(%{action: :get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call(houseInfos, _from, state) do
    to = houseInfos["request"]["to"]
    body = houseInfos["request"]["body"] |> Poison.encode!
    headers = houseInfos["request"]["headers"] || []
    method = houseInfos["request"]["method"] |> String.downcase |> String.to_atom

    Log.info(@m, "#{method} request to #{to}")

    case HTTPoison.request(method, to, body, headers) do
      {:ok, response} ->
        Log.info(@m, "Response code: #{response.status_code}")
        {:reply, response, state}

      {:error, error} ->
        Log.info(@m, "Error: #{inspect error.reason}")
        {:reply, {:error, error.reason}, state}
    end
  end
end