defmodule RequestFormatter do

  @m __MODULE__
  @regexPattern ~r/\{\{(.*?)\}\}/   # everything between {{ and }}

  def replace_values_in_map(mapToUpdate, dataMap) do
    stringToUpdate = Poison.encode!(mapToUpdate)                                       # (...) http://localhost:3000/events/{{event.id}} (...)
    elemsToReplace = Regex.scan(@regexPattern, stringToUpdate)                         # [ ["{{event.id}}", "event.id"], (...) ]

    Log.debug(@m, "Starting to replace values in #{stringToUpdate} with dataMap #{inspect dataMap}")

    updatedString =
      Enum.reduce(elemsToReplace, stringToUpdate, fn(elemToReplace, updatedString) ->  # ["{{event.id}}", "event.id"]
        valueToReplace = elemToReplace |> Enum.at(0)                                   # "{{event.id}}"
        pathToNewValue = elemToReplace |> Enum.at(1) |> String.split(".")              # ["event", "id"]

        case find_value_from_nested_map(dataMap, pathToNewValue) do
          nil ->
            Log.debug(@m, "Could not find: #{inspect pathToNewValue} in data map: #{inspect dataMap}")
            updatedString
          newValue ->
            replace_in_string(updatedString, valueToReplace, newValue)
        end
      end)

    Log.info(@m, "Done: #{updatedString}")

    Poison.decode! updatedString
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
