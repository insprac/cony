defmodule Cony.Parser do
  @moduledoc """
  Provides a method to parse environment variables.
  """

  alias Cony.Parser.ParseError

  @spec parse(Cony.variable_type, Cony.variable_value)
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

  def parse(:boolean, "true"), do: {:ok, true}
  def parse(:boolean, "false"), do: {:ok, false}
  def parse(:boolean, _), do: {:ok, nil}

  def parse({:list, type}, value) do
    parse({:list, type, delimiter: ","}, value)
  end

  def parse({:list, inner_type, options}, value) do
    delimiter = Keyword.get(options, :delimiter, ",")
    values = String.split(value, delimiter)
    parse_list(inner_type, values, [])
  end

  def parse(type, value) do
    {:error, ParseError.create(type, value, "invalid type")}
  end

  defp parse_list(_type, [], results), do: {:ok, results}
  defp parse_list(type, [raw_value | raw_values], values) do
    case parse(type, raw_value) do
      {:ok, value} -> parse_list(type, raw_values, values ++ [value])
      {:error, error} -> {:error, error}
    end
  end
end
