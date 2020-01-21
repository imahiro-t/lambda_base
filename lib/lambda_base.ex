defmodule LambdaBase do
  @moduledoc """
  This is lambda base.
  Use LambdaBase and implement `handle(event, context)` function
  """

  @doc """
  Lambda runtime call handle function.
  """
  @callback handle(event :: map(), context :: map()) :: {:ok, String.t} | {:error, String.t}

  defmacro __using__(_opts) do
    quote do
      alias Util.Json
      alias Util.LambdaLogger
      @behaviour LambdaBase
    end
  end

end
