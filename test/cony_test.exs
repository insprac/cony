defmodule ConyTest do
  use ExUnit.Case, asyn: true

  defmodule TestConfig do
    import Cony

    config prefix: "test_" do
      var :some_string, :string, default: "test string"
      var :some_number, :integer
      var :not_set, :string
    end
  end

  test "get/1 returns the correct environment variable" do
    System.put_env("TEST_SOME_STRING", "some value")
    System.put_env("TEST_SOME_NUMBER", "42")

    assert TestConfig.get(:some_string) == "some value"
    assert TestConfig.get(:some_number) == 42
    assert TestConfig.get(:not_set) == nil
  end

  test "get/1 raises an error when undefined" do
    assert_raise Cony.UndefinedVariableError, fn ->
      TestConfig.get(:does_not_exist)
    end
  end

  test "get/1 raises an error when value cannot be parsed" do
    System.put_env("TEST_SOME_NUMBER", "not a number")
    assert_raise Cony.Parser.ParseError, fn ->
      TestConfig.get(:some_number)
    end
  end

  test "get!/1 returns the corrent environment variable" do
    System.put_env("TEST_SOME_STRING", "some string")
    System.put_env("TEST_SOME_NUMBER", "123")

    assert TestConfig.get!(:some_string) == "some string"
    assert TestConfig.get!(:some_number) == 123
  end

  test "get!/1 raises an error when not set" do
    assert_raise Cony.MissingVariableError, fn ->
      TestConfig.get!(:not_set)
    end
  end
end
