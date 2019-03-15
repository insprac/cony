defmodule Cony.Parser.ParseError do
  defexception type: nil, value: nil, message: "invalid value"

  @type t :: %__MODULE__{
    type: Cony.variable_type,
    value: Cony.variable_value,
    message: String.t
  }

  @doc """
  Simple helper function for generating a `ParseError` struct.

  ## Example

      iex> create(:float, "bad value")
      %Cony.Parser.ParseError{
        type: :float,
        value: "bad value",
        message: "invalid value"
      }

      iex> create(:integer, "bad value", "variable is not a number")
      %Cony.Parser.ParseError{
        type: :integer,
        value: "bad value",
        message: "variable is not a number"
      }

  """
  @spec create(Cony.variable_type, Cony.variable_value, String.t) :: t
  def create(type, value, message \\ "invalid value") do
    %__MODULE__{type: type, value: value, message: message}
  end

  @spec message(t) :: String.t
  def message(%__MODULE__{type: type, value: value, message: message}) do
    """
    Unable to parse value: #{message}
      type: #{inspect(type)}
      value: #{value}
    """
  end
end
