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
      LambdaBase.Base.loop(context)
    else
      :ok
    end
  end

end
