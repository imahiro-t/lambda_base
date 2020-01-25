defmodule LambdaBase.Application do

  use Application

  alias Util.LambdaLogger
  alias LambdaBase.CommonBase

  def start(_type, _args) do
    context = System.get_env
    children = [
      {LambdaLogger, context |> CommonBase.log_level}
    ]
    Supervisor.start_link(children, strategy: :one_for_all)
    CommonBase.loop(context)
  end


end
