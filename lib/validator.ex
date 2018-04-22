defmodule Validator do

  import Request

  def validateStatusCode(requestInfos, response) do
    valid = case response do
      {:error, _} -> false
      _ -> get_from_request(requestInfos, :responseExpect) == response.status_code
    end
    print_feedback(requestInfos, response, valid)
    valid
  end

  defp print_feedback(requestInfos, response, valid) do
    output = "" <>
      if (get_from_request(requestInfos, :name) != nil) do
        "#{get_from_request(requestInfos, :name)}"
      else
        "#{get_from_request(requestInfos, :requestMethod)} #{get_from_request(requestInfos, :requestTo)}"
      end

    output = output <> "\n ╚ Expected: #{get_from_request(requestInfos, :responseExpect)}"

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
