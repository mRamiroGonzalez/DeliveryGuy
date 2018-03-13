defmodule Validator do

  def validateResponse(houseInfos, response) do
    expectation = houseInfos["response"]["expect"]
    response = response.status_code
    expectation == response
  end

end
