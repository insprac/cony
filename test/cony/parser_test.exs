defmodule Cony.ParserTest do
  use ExUnit.Case, async: true

  alias Cony.Parser.ParseError

  test "parse/1 returns expected values" do
    assert {:ok, "value"} = Cony.Parser.parse(:string, "value")
    assert {:ok, "some string"} = Cony.Parser.parse(:string, "some string")
    assert {:ok, ""} = Cony.Parser.parse(:string, "")
    assert {:ok, 42} = Cony.Parser.parse(:integer, "42")
    assert {:ok, 1.3} = Cony.Parser.parse(:float, "1.3")
    assert {:ok, 1.0} = Cony.Parser.parse(:float, "1")

    assert {:error, %ParseError{}} = Cony.Parser.parse(:integer, "abc")
    assert {:error, %ParseError{}} = Cony.Parser.parse(:float, "lkjsdf")
  end
end
