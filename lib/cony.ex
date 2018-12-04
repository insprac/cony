defmodule Cony do
  @moduledoc """
  Provides macros for defining a config module that uses environment variables.

  Here is an example implementation with `Ecto`:

      # ~/.bash_profile
      MY_APP_REPO_USERNAME="root"
      MY_APP_REPO_PASSWORD="s3cr3t"
      MY_APP_REPO_DATABASE="my_app"
      MY_APP_REPO_HOSTNAME="localhost"
      

      defmodule MyApp.RepoConfig do
        import Cony

        config env_prefix: "my_app_repo_" do
          var :username, :string
          var :password, :string
          var :database, :string
          var :hostname, :string, default: "localhost"
        end
      end

      defmodule MyApp.Repo do
        use Ecto.Repo, otp_app: :my_app, adapter: Ecto.Adapters.Postgres
    
        def init(_, config) do
          config = Keyword.merge(config, [
            username: MyApp.RepoConfig.get!(:username),
            password: MyApp.RepoConfig.get!(:password),
            database: MyApp.RepoConfig.get!(:database),
            hostname: MyApp.RepoConfig.get!(:hostname)
          ])

          {:ok, config}
        end
      end

  ## Parsers

  The parser is responsible for the conversion of environment variables into
  elixir types.

  Custom parsers can be provided at the module or variable level:

      defmodule MyApp.ConfigParser do
        def parse(:string, value), do: {:ok, value}
        def parse(:integer, value), do: #...
      end

      defmodule MyApp.ListParser do
        def parse({:list, delimiter, subtype}, value) do
          results =
            value
            |> String.split(delimiter)
            |> Enum.map(&parse(subtype, &1))

          case Enum.all?(results, fn {status, _} -> status == :ok end) do
            true ->
              {:ok, Enum.map(results, fn {_, value} -> value end)}
            false ->
              {:error, Cony.Parser.ParseError.create(
                {:list, delimiter, subtype}, value, "invalid list element"})}
          end
        end
      end

      defmodule MyApp.Config do
        import Cony

        config parser: MyApp.ConfigParser do
          var :some_text, :string
          var :some_list, {:list, " ", :string}, parser: MyApp.ListParser
        end
      end

  """
  @type config_options :: list({:prefix, String.t} | {:parser, module})
  @type var :: {var_type, var_options}
  @type var_type :: :string | :integer | atom
  @type var_key :: atom
  @type var_name :: String.t
  @type var_value :: String.t
  @type var_options :: list({:default, any} | {:parser, module})

  @spec config(config_options, Keyword.t) :: :ok
  defmacro config(opts \\ [], do: block) do
    quote do
      import Cony, only: [var: 2, var: 3]

      Module.register_attribute(__MODULE__, :variables, accumulate: true)

      @env_prefix unquote(Keyword.get(opts, :env_prefix, ""))
      @parser unquote(Keyword.get(opts, :parser, Cony.Parser))

      unquote(block)

      @spec get(Cony.var_key) :: any
      def get!(key) do
        {type, opts} = find_variable(key)
        name = variable_name(key)

        case System.get_env(name) do
          nil -> raise Cony.MissingVariableError, {key, name}
          value -> parse_value(type, value, opts)
        end
      end

      @spec get(Cony.var_key) :: any
      def get(key) do
        {type, opts} = find_variable(key)
        name = variable_name(key)

        case System.get_env(name) do
          nil -> nil
          value -> parse_value(type, value, opts)
        end
      end

      @spec variable_name(Cony.var_key) :: Cony.var_name
      defp variable_name(key) do
        String.upcase("#{@env_prefix}#{key}")
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

      @spec parse_value(Cony.var_type, Cony.var_value, Cony.var_options) :: any
      defp parse_value(type, value, opts) do
        parser = Keyword.get(opts, :parser, @parser)

        case parser.parse(type, value) do
          {:ok, value} -> value
          {:error, error} -> raise error
        end
      end

      :ok
    end
  end

  @spec var(var_key, var_type, var_options) :: :ok
  defmacro var(key, type, opts \\ []) do
    quote do
      variable = {unquote(key), {unquote(type), unquote(opts)}}
      Module.put_attribute(__MODULE__, :variables, variable)

      :ok
    end
  end
end
