defmodule LambdaBase.Util.LambdaConfig do
  @moduledoc """
  A Config for AWS Lambda.

  store `config/release.exs`
  """

  use Agent

  @type on_start() :: {:ok, pid()} | {:error, {:already_started, pid()} | term()}
  @external_resource config_file = "../../config/lambda.exs"
  config = if (File.exists?(config_file)), do: Config.Reader.read!(config_file), else: []

  @doc """
  Start Config.

  """
  @spec start_link() :: on_start()
  def start_link(), do: start_link([])
  def start_link(_initial_value) do
    Agent.start_link(fn -> unquote(config) end, name: __MODULE__)
  end

  @doc """
  Get configration.
  """
  def get(keys), do: get(keys, nil)
  def get(keys, default), do: Agent.get(__MODULE__, & &1) |> get_value(keys, default)

  defp get_value(nil, _, default), do: default
  defp get_value(config, [], _default), do: config
  defp get_value(config, [key | keys], default), do: get_value(config |> Keyword.get(key), keys, default)
end