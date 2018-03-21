defmodule Validator do

  def validateStatusCode(requestInfos, response) do
    valid = case response do
      {:error, reason} -> false
      _ -> requestInfos["response"]["expect"] == response.status_code
    end
    print_feedback(requestInfos, response, valid)
    valid
  end

  def print_feedback(requestInfos, response, valid) do
    output = "" <>
      if (requestInfos["name"] != nil) do
        "#{requestInfos["name"]}"
      else
        "#{requestInfos["request"]["method"]} #{requestInfos["request"]["to"]}"
      end

    output = output <> "\n ╚ Expected: #{requestInfos["response"]["expect"]}"

    output = output <>
      if (not valid) do
       " - FAILURE \n    ╚" <>
        case response do
          {:error, reason} ->
            "Error: #{reason}"
          response ->
            " Response code: #{response.status_code}\n    ╚ Response body: #{response.body}"
        end
      else
        " ✔"
      end

    IO.puts output
  end
end
