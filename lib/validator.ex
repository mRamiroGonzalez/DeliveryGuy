defmodule Validator do

  def validateStatusCode(requestInfos, response) do
    valid = requestInfos["response"]["expect"] == response.status_code
    output = "#{requestInfos["request"]["method"]} #{requestInfos["request"]["to"]}"
    output = output <> "\n ╚ Expected: #{requestInfos["response"]["expect"]}"
    output =
      output <> if (not valid) do
        " - FAILURE \n    ╚ Response code: #{response.status_code}\n    ╚ Response body: #{inspect response.body}"
      else
        " ✔"
      end
    IO.puts output
    valid
  end


end
