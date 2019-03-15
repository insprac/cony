defmodule Cony.MissingVariableError do
  defexception [:key, :name]

  @type t :: %__MODULE__{
    key: Cony.variable_key,
    name: Cony.variable_name
  }

  @spec exception({Cony.variable_key, Cony.variable_name}) :: Exception.t
  def exception({key, name}) do
    %__MODULE__{key: key, name: name}
  end

  @spec message(t) :: String.t
  def message(%__MODULE__{key: key, name: name}) do
    """
    Missing environment variable #{name}
      variable key: :#{key}
      variable name: #{name}
    """
  end
end
