defmodule LambdaBase.BaseTask do

  use Task

  @doc """
  Start BaseTask.
  """
  def start_link(context) do
    Task.start_link(__MODULE__, :run, [context])
  end

  @doc """
  Start run LambdaBase.Base.loop.
  """
  def run(context) do
    if (context |> Map.has_key?("AWS_LAMBDA_RUNTIME_API")) do
      case context |> LambdaBase.Base.init() do
        {:ok, context} ->
          LambdaBase.Base.loop(context)
        _ ->
          :halt
      end
    else
      :halt
    end
  end

end
