defmodule Deliveryguy do

  use GenServer

  @m __MODULE__

  # CLIENT
  def get_state(pid) do
    GenServer.call(pid, %{action: :get_state})
  end

  def make_request(pid, requestInfos, dispatcherPid) do
    updatedRequestInfos = update_request_infos(requestInfos, pid, dispatcherPid)

    case GenServer.call(pid, updatedRequestInfos) do
      {:error, _reason} -> nil
      response ->
        responseBody = Poison.decode! response.body
        if(Validator.validateStatusCode(updatedRequestInfos, response)) do
          save_entity(requestInfos, responseBody, pid, dispatcherPid)
          :true
        else
          :false
        end
    end
  end

  defp update_request_infos(requestInfos, currentRoutePid, dispatcherPid) do
    Log.info(@m, "Updating values with global and route variables")

    # global variables are always overridden in case of a conflict
    globalVariables = Dispatcher.get_state(dispatcherPid)
    routeVariables = get_state(currentRoutePid)
    mergedMap = Map.merge(globalVariables, routeVariables)

    RequestFormatter.replace_values_in_map(requestInfos, mergedMap)
  end

  defp save_entity(requestInfos, responseBody, currentRoutePid, dispatcherPid) do
    entityName = requestInfos["response"]["entityName"]
    entityType = requestInfos["response"]["type"]

    Log.info(@m, "New variable: #{entityName} as #{inspect responseBody}")

    if(entityName != nil) do
      if(entityType == "global") do
        Dispatcher.add_global_entity(dispatcherPid, entityName, responseBody)
      else
        add_entity(currentRoutePid, entityName, responseBody)
      end
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

    Log.info(@m, "#{String.upcase(houseInfos["request"]["method"])} request to #{to}")

    case Httpclient.send(%{to: to, body: body, headers: headers, method: method}) do
      {:ok, response} -> {:reply, response, state}
      {:error, error} -> {:reply, {:error, error.reason}, state}
    end
  end
end