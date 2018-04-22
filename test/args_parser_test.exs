defmodule ArgsParserTest do
  use ExUnit.Case

  test "main_noArgs_failure" do
    result = ArgsParser.main()
    assert result == -1
  end

  test "main_failure" do
    result = ArgsParser.main(["--source", "exampleRequests/will-fail.json"])
    assert result == -1
  end

  test "main_success" do
    result = ArgsParser.main(["--source", "exampleRequests/will-success.json"])
    assert result == 0
  end
end