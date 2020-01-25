defmodule LambdaBase do
  @moduledoc """
  This is lambda base.
  Use LambdaBase and implement `handle(event, context)` function
  """

  alias Util.LambdaLogger
  alias LambdaBase.CommonBase

  @doc """
  Lambda runtime call handle function.
  """
  @callback handle(event :: map(), context :: map()) :: {:ok, String.t} | {:error, String.t}

  defmacro __using__(_opts) do
    quote do
      alias Util.Json
      alias Util.LambdaLogger
      @behaviour LambdaBase
      def start() do
        context = System.get_env
        LambdaLogger.start_link(context |> CommonBase.log_level)
        HTTPoison.start()
        CommonBase.loop(context)
      end
    end
  end
end
