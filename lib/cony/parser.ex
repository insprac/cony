defmodule Cony.Parser do
  @moduledoc """
  Provides a method to parse environment variables.
  """

  alias Cony.Parser.ParseError

  @spec parse(Cony.var_type, Cony.var_value) 
  :: {:ok, any} | {:error, ParseError.t}
  def parse(:string, value) do
    {:ok, value}
  end

  def parse(:integer, value) do
    case Integer.parse(value) do
      {integer, _} ->
        {:ok, integer}
      _ ->
        {:error, ParseError.create(:integer, value, "not an integer")}
    end
  end

  def parse(:float, value) do
    case Float.parse(value) do
      {float, _} -> 
        {:ok, float}
      _ ->
        {:error, ParseError.create(:float, value, "not a float")}
    end
  end

  def parse(type, value) do
    {:error, ParseError.create(type, value, "invalid type")}
  end
end
