defmodule LambdaBase.Util.LambdaConfig do
  @moduledoc """
  A Config for AWS Lambda.

  store `config/release.exs`
  """

  use Agent

  @type on_start() :: {:ok, pid()} | {:error, {:already_started, pid()} | term()}
  @config_file "config/release.exs"

  @doc """
  Start Config.

  """
  @spec start_link() :: on_start()
  def start_link(), do: start_link([])
  def start_link(_initial_value) do
    config = if (File.exists?(@config_file)), do: Config.Reader.read!(@config_file), else: []
    Agent.start_link(fn -> config end, name: __MODULE__)
  end

  @doc """
  Get configration.
  """
  def get(keys), do: Agent.get(__MODULE__, & &1) |> get(keys)
  def get(nil, _), do: nil
  def get(config, []), do: config
  def get(config, [key | keys]), do: get(config |> Keyword.get(key), keys)
end