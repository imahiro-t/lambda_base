defmodule LambdaBase do
  @moduledoc """
  This is lambda base.
  Use LambdaBase and implement `handle(event, context)` function
  """

  @doc """
  Lambda runtime call init function.
  """
  @callback init(context :: map()) :: {:ok, map()}

  @doc """
  Lambda runtime call handle function.
  """
  @callback handle(event :: map(), context :: map()) :: {:ok, String.t} | {:error, String.t}

  defmacro __using__(_opts) do
    quote do
      @behaviour LambdaBase
      def start() do
        context = System.get_env
        HTTPoison.start()
        {:ok, context} = init(context)
        LambdaBase.Base.loop(context)
      end
    end
  end
end
