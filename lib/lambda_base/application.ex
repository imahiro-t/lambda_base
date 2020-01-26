defmodule LambdaBase.Application do

  use Application

  alias LambdaBase.Util.LambdaLogger

  def start(_type, _args) do
    context = System.get_env
    children = [
      {LambdaLogger, context |> LambdaBase.Base.log_level}
    ]
    Supervisor.start_link(children, strategy: :one_for_all)
    LambdaBase.Base.loop(context)
  end

end
