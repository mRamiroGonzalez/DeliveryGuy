defmodule Deliveryguy do

  use GenServer


  # CLIENT
  def get_state(pid) do
    GenServer.call(pid, %{action: :get_state})
  end

  def deliver_house(pid, houseInfos) do
    houseInfos = replace_entities_from_state(Poison.encode!(houseInfos), get_state(pid))

    response = GenServer.call(pid, houseInfos)
    responseBody = Poison.decode! response.body

    if(Validator.validateStatusCode(houseInfos, response)) do
      entityName = houseInfos["response"]["entityName"]
      if(entityName != nil) do
        add_entity(pid, entityName, responseBody)
      end
    end

    response.status_code
  end

  def add_entity(pid, name, entity) do
    GenServer.call(pid, %{action: :add, name: name, entity: entity})
  end

  def get_globals(pid) do
    GenServer.call(pid, %{action: :get_globals})
  end

  defp replace_entities_from_state(houseInfosJson, state) do
    Enum.reduce(state, houseInfosJson, fn ({name, data}, _acc) ->
      encodedEntity = Poison.encode!(data)
      toReplace = "\"{{" <> name <> "}}\""
      String.replace(houseInfosJson, toReplace, encodedEntity)
    end)
    |> Poison.decode!
  end


  # INIT
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end


  # SERVER
  def handle_call(%{action: :add, name: name, entity: entity}, _from, state) do
    {:reply, :ok, Map.put(state, name, entity)}
  end

  def handle_call(%{action: :get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call(%{action: :get_globals}, _from, state) do
    {:reply, Globals.get_state(state["globalsPid"]), state}
  end

  def handle_call(houseInfos, _from, state) do
    to = houseInfos["request"]["to"]
    body = houseInfos["request"]["body"] |> Poison.encode!
    headers = houseInfos["request"]["headers"] || []
    method = houseInfos["request"]["method"] |> String.downcase |> String.to_atom

    response = HTTPoison.request!(method, to, body, headers)
    {:reply, response, state}
  end
end