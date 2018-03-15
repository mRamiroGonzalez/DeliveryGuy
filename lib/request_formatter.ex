defmodule RequestFormatter do

  @m __MODULE__
  @regexPattern ~r/\{\{(.*?)\}\}/   # everything between {{ and }}

  def replace_values_in_map(mapToUpdate, dataMap) do
    jsonString = Poison.encode!(mapToUpdate)                                     # (...) http://localhost:3000/events/{{event.id}} (...)
    toBeReplaced = Regex.scan(@regexPattern, jsonString)                         # [ ["{{event.id}}", "event.id"], (...) ]

    Enum.reduce(toBeReplaced, jsonString, fn(replaceKey, updatedJsonString) ->   # ["{{event.id}}", "event.id"]
      keyString =  replaceKey |> Enum.at(0)                                      # "{{event.id}}"
      keysArray  = replaceKey |> Enum.at(1) |> String.split(".")                 # ["event", "id"]

      newValue = get_value_from_nested_map(keysArray, dataMap)                   # get entity value in state
      update_infos(updatedJsonString, keyString, newValue)                       # and put it in the request
    end)
    |> Poison.decode!
  end

  defp update_infos(jsonString, key, value) when is_map(value) do
    encoded = Poison.encode!(value)
    toReplace = "\"" <> key <> "\""
    Log.debug(@m, "Replacing #{toReplace} with #{encoded}")
    String.replace(jsonString, toReplace, encoded)
  end
  defp update_infos(jsonString, key, value) do
    Log.debug(@m, "Replacing #{key} with #{value}")
    String.replace(jsonString, key, "#{value}")
  end

  defp get_value_from_nested_map(keys, map) do
    Enum.reduce(keys, map, fn(key, currentMap) -> Map.get(currentMap, key) end)
  end

end
