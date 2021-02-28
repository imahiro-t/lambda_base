defmodule LambdaBase.Application do

  use Application

  def start(_type, _args) do
    context = System.get_env
    children = [
      {LambdaBase.BaseTask, context}
    ]
    Supervisor.start_link(children, strategy: :one_for_all)
  end

end
