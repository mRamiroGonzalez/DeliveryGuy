defmodule Validator do

  def validateStatusCode(requestInfos, response) do
    valid = case response do
      {:error, _} -> false
      _ -> requestInfos["response"]["expect"] == response.status_code
    end
    print_feedback(requestInfos, response, valid)
    valid
  end

  defp print_feedback(requestInfos, response, valid) do
    output = "" <>
      if (requestInfos["name"] != nil) do
        "#{requestInfos["name"]}"
      else
        "#{requestInfos["request"]["method"]} #{requestInfos["request"]["to"]}"
      end

    output = output <> "\n ╚ Expected: #{requestInfos["response"]["expect"]}"

    output = output <>
      if (valid) do
        " ✔"
      else
        " - FAILURE \n    ╚" <>
        case response do
          {:error, reason} ->
            " Error: #{reason}"
          response ->
            " Response code: #{response.status_code}\n    ╚ Response body: #{response.body}"
        end
      end
    IO.puts output
  end
end
