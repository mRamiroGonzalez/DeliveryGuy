defmodule Validator do

  def validateStatusCode(requestInfos, response) do
    valid = requestInfos["response"]["expect"] == response.status_code
    print_feedback(requestInfos, response, valid)
  end

  def print_feedback(requestInfos, response, valid) do
    output =
      "#{requestInfos["request"]["method"]} #{requestInfos["request"]["to"]}"
      <> "\n ╚ Expected: #{requestInfos["response"]["expect"]}"
      <> if (not valid) do
        " - FAILURE \n    ╚ Response code: #{response.status_code}\n    ╚ Response body: #{inspect response.body}"
      else
        " ✔"
      end
    IO.puts output
    valid
  end
end
