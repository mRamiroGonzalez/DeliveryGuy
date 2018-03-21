defmodule ValidatorTest do
  use ExUnit.Case

  test "valid_request_from_status" do
    filename = "test/routes/create-event.json"

    houseInfos =
      filename
      |> File.read!
      |> Poison.decode!
      |> Map.get("sync")
      |> List.first

    response = %{status_code: 201}

    result = Validator.validateStatusCode(houseInfos, response)

    assert result == true
  end

  test "invalid_request_from_status" do
    filename = "test/routes/create-event.json"

    houseInfos =
      filename
      |> File.read!
      |> Poison.decode!
      |> Map.get("sync")
      |> List.first

    response = %{status_code: 200, body: ""}

    result = Validator.validateStatusCode(houseInfos, response)

    assert result == false
  end
end
