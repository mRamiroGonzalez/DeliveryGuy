defmodule Deliveryguy do

  use GenServer


  # CLIENT
  def get_state(pid) do
    GenServer.call(pid, %{action: :get_state})
  end

  def deliver_house(pid, houseInfos) do
    houseInfos = replace_entities_from_state(houseInfos, get_state(pid))

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

  defp replace_entities_from_state(requestInfos, state) do
    requestInfosJson = Poison.encode!(requestInfos)                                   # (...) http://localhost:3000/events/{{event.id}} (...)
    toBeReplaced = Regex.scan(~r/\{\{(.*?)\}\}/, requestInfosJson)                    # [ ["{{event.id}}", "event.id"], (...) ]

    Enum.reduce(toBeReplaced, requestInfosJson, fn(replaceKey, updatedInfosJson) ->   # ["{{event.id}}", "event.id"]
      replaceKeyString   = replaceKey |> Enum.at(0)                                   # "{{event.id}}"
      replaceKeySequence = replaceKey |> Enum.at(1) |> String.split(".")              # ["event", "id"]

      newValue =
        Enum.reduce(replaceKeySequence, state, fn(key, currentMap) ->
          Map.get(currentMap, key)
        end)

      if(is_map(newValue)) do
        encoded = Poison.encode!(newValue)
        toReplace = "\"" <> replaceKeyString <> "\""
        String.replace(updatedInfosJson, toReplace, encoded)
      else
        String.replace(updatedInfosJson, replaceKeyString, "#{newValue}")
      end

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