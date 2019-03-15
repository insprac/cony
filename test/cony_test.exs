defmodule ConyTest do
  use ExUnit.Case, asyn: true

  defmodule WrapParser do
    def parse(:string, value), do: {:ok, "<<#{value}>>"}
  end

  defmodule TestConfig do
    import Cony

    config env_prefix: "test_" do
      add :some_string, :string, default: "test string"
      add :some_number, :integer
      add :not_set, :string
      add :wrap, :string, parser: WrapParser
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

  test "get!/1 returns the correct environment variable" do
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

  test "variables can be given a specific parser" do
    System.put_env("TEST_WRAP", "some string")
    assert TestConfig.get(:wrap) == "<<some string>>"
  end
end
