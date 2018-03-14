defmodule Validator do

  def validateStatusCode(houseInfos, response), do: houseInfos["response"]["expect"] == response.status_code

end
