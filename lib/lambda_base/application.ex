defmodule LambdaBase.Application do

  use Application

  alias LambdaBase.Logger

  def start(_type, _args) do
    context = System.get_env
    children = [
      {Logger, context |> Map.get("LOG_LEVEL", "INFO") |> String.downcase |> String.to_atom},
      {LambdaBase.BaseTask, context}
    ]
    Supervisor.start_link(children, strategy: :one_for_all)
  end

end
