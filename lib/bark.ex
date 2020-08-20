defmodule Bark do
  require Logger

  defmacro __using__(_opts) do
    quote do
      @spec debug(Keyword.t()) :: :ok
      def debug(opts), do: debug(unquote(__CALLER__), opts)
      @spec info(Keyword.t()) :: :ok
      def info(opts), do: info(unquote(__CALLER__), opts)
      @spec warn(Keyword.t()) :: :ok
      def warn(opts), do: warn(unquote(__CALLER__), opts)
      @spec error(Keyword.t()) :: :ok
      def error(opts), do: error(unquote(__CALLER__), opts)
    end
  end

  # Logs a list of kv pairs
  @spec debug(any(), Keyword.t()) :: any()
  def debug(env, opts), do: Logger.debug(parse_message(env, opts))

  @spec info(any(), Keyword.t()) :: any()
  def info(env, opts), do: Logger.info(parse_message(env, opts))

  @spec warn(any(), Keyword.t()) :: any()
  def warn(env, opts), do: Logger.warn(parse_message(env, opts))

  @spec error(any(), Keyword.t()) :: any()
  def error(env, opts), do: Logger.error(parse_message(env, opts))

  defp parse_message(env, opts) do
    {function_name, arity} =
      env
      |> Map.get(:function)
      |> case do
        {function_name, arity} -> {function_name, arity}
        _ -> {"None", 0}
      end

    module =
      env
      |> Map.get(:module)
      |> case do
        nil -> "None"
        module -> module |> Atom.to_string() |> String.replace("Elixir.", "")
      end

    Enum.reduce(
      opts,
      "module=#{module} command=#{function_name}/#{arity}",
      fn {k, v}, acc ->
        "#{acc} #{Atom.to_string(k)}=#{log_value(v)}"
      end
    )
  end

  # Quote string if it contains a space
  defp quote_if_spaces(value) when is_binary(value) do
    if String.contains?(value, " ") do
      "\"#{value}\""
    else
      value
    end
  end

  defp log_value(value) when is_binary(value), do: quote_if_spaces(value)

  defp log_value(value) when is_atom(value), do: Atom.to_string(value)

  defp log_value(value), do: quote_if_spaces(inspect(value))
end
