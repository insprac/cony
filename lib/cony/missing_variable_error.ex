defmodule Cony.MissingVariableError do
  defexception [:key, :name]

  @type t :: %__MODULE__{
    key: Cony.var_key,
    name: Cony.var_name
  }

  @spec exception({Cony.var_key, Cony.var_name}) :: t
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
