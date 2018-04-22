defmodule Request do

  def get_from_request(map, key) do
    case key do
      :name -> map["name"]
      :requestTo -> map["request"]["to"]
      :requestBody -> map["request"]["body"]
      :requestHeaders -> map["request"]["headers"]
      :requestMethod -> map["request"]["method"]
      :responseType -> map["response"]["type"]
      :responseEntityName -> map["response"]["entityName"]
      :responseExpect -> map["response"]["expect"]
    end
  end
end
