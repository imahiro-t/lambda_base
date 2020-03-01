defmodule LambdaBase.Application do

  use Application

  alias LambdaBase.Util.LambdaLogger
  alias LambdaBase.Util.LambdaConfig

  def start(_type, _args) do
    context = System.get_env
    children = [
      {LambdaLogger, context |> LambdaBase.Base.log_level},
      {LambdaConfig, []},
      {LambdaBase.BaseTask, context}
    ]
    Supervisor.start_link(children, strategy: :one_for_all)
  end

end
