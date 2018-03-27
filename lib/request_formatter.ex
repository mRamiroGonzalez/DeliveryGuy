defmodule RequestFormatter do

  @m __MODULE__
  @regexPattern ~r/\{\{(.*?)\}\}/   # everything between {{ and }}

  def replace_values_in_map(mapToUpdate, dataMap) do
    jsonToUpdate = Poison.encode!(mapToUpdate)                                         # (...) http://localhost:3000/events/{{event.id}} (...)
    elemsToReplace = Regex.scan(@regexPattern, jsonToUpdate)                           # [ ["{{event.id}}", "event.id"], (...) ]

    Log.debug(@m, "Starting to replaces values in #{jsonToUpdate} with dataMap #{inspect dataMap}")

    updatedJson =
      Enum.reduce(elemsToReplace, jsonToUpdate, fn(elemToReplace, updatedJson) ->      # ["{{event.id}}", "event.id"]
        valueToReplace = elemToReplace |> Enum.at(0)                                   # "{{event.id}}"
        pathToNewValue = elemToReplace |> Enum.at(1) |> String.split(".")              # ["event", "id"]

        case find_value_from_nested_map(dataMap, pathToNewValue) do
          nil ->
            Log.debug(@m, "Could not find: #{inspect pathToNewValue} in data map: #{inspect dataMap}")
            updatedJson
          newValue ->
            replace_in_string(updatedJson, valueToReplace, newValue)
        end
      end)

    Log.info(@m, "Done: #{updatedJson}")

    Poison.decode! updatedJson
  end

  defp replace_in_string(string, key, value) when is_map(value) do
    valueAsJson = Poison.encode!(value)
    substringToReplace = "\"" <> key <> "\""

    Log.debug(@m, "Replacing #{substringToReplace} with #{valueAsJson}")

    String.replace(string, substringToReplace, valueAsJson)
  end

  defp replace_in_string(string, key, value) do
    Log.debug(@m, "Replacing #{key} with #{value}")

    String.replace(string, key, "#{value}")
  end

  defp find_value_from_nested_map(map, pathToValue) do
    Enum.reduce(pathToValue, map, fn (key, currentMap) ->
      if (currentMap != nil) do
        Map.get(currentMap, key)
      end
    end)
  end

end
