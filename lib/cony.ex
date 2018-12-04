defmodule Cony do
  @type var :: {var_type, var_options}
  @type var_type :: :string | :integer | atom
  @type var_key :: atom
  @type var_name :: String.t
  @type var_value :: String.t
  @type var_options :: {:default, any}

  defmacro config(opts \\ [], do: block) do
    quote do
      import Cony, only: [var: 2, var: 3]

      Module.register_attribute(__MODULE__, :variables, accumulate: true)

      @prefix unquote(Keyword.get(opts, :prefix, ""))
      @parser unquote(Keyword.get(opts, :parser, Cony.Parser))

      unquote(block)

      @spec get(Cony.var_key) :: any
      def get!(key) do
        {type, opts} = find_variable(key)
        name = variable_name(key)

        case System.get_env(name) do
          nil -> raise Cony.MissingVariableError, {key, name}
          value -> parse_value(type, value)
        end
      end

      @spec get(Cony.var_key) :: any
      def get(key) do
        {type, opts} = find_variable(key)
        name = variable_name(key)

        case System.get_env(name) do
          nil -> nil
          value -> parse_value(type, value)
        end
      end

      @spec variable_name(Cony.var_key) :: Cony.var_name
      defp variable_name(key) do
        String.upcase("#{@prefix}#{key}")
      end

      @spec find_variable(Cony.var_key) :: Cony.var
      defp find_variable(key) do
        case Enum.find(@variables, fn {k, _} -> k == key end) do
          {_key, {type, options}} ->
            {type, options}
          value ->
            raise Cony.UndefinedVariableError, key
        end
      end

      @spec parse_value(Cony.var_type, Cony.var_value) :: any
      defp parse_value(type, value) do
        case @parser.parse(type, value) do
          {:ok, value} -> value
          {:error, error} -> raise error
        end
      end
    end
  end

  defmacro var(key, type, opts \\ []) do
    quote do
      variable = {unquote(key), {unquote(type), unquote(opts)}}
      Module.put_attribute(__MODULE__, :variables, variable)
    end
  end
end
