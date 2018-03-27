defmodule ValidatorTest do
  use ExUnit.Case

  @testFilesPath "test/routes/validator/"

  test "validate_statusCode_success" do
    filename = @testFilesPath <> "create-event.json"

    requestInfos =
      filename
      |> File.read!
      |> Poison.decode!
      |> Map.get("sync")
      |> List.first

    response = %{status_code: 201}

    assert Validator.validateStatusCode(requestInfos, response)
  end

  test "validate_statusCode_failure" do
    filename = @testFilesPath <> "create-event.json"

    requestInfos =
      filename
      |> File.read!
      |> Poison.decode!
      |> Map.get("sync")
      |> List.first

    response = %{status_code: 200, body: ""}

    assert not Validator.validateStatusCode(requestInfos, response)
  end
end
