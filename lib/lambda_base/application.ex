defmodule LambdaBase.Application do

  use Application

  alias LambdaBase.Util.LambdaLogger

  def start(_type, _args) do
    context = System.get_env
    children = [
      {LambdaLogger, context |> Map.get("LOG_LEVEL", "INFO") |> String.downcase |> String.to_atom},
      {LambdaBase.BaseTask, context}
    ]
    Supervisor.start_link(children, strategy: :one_for_all)
  end

end
