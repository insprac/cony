defmodule Cony.UndefinedVariableError do
  defexception [:key]

  @type t :: %__MODULE__{key: Cony.var_key}

  @spec exception(Cony.var_key) :: t
  def exception(key), do: %__MODULE__{key: key}

  @spec message(t) :: String.t
  def message(%__MODULE__{key: key}) do
    "Environment variable has not been defined :#{key}"
  end
end
