defmodule LambdaBase.Util.LambdaLogger do

  alias LambdaBase.Logger

  @doc """
  Log Debug.
  """
  @deprecated "Use LambdaBase.Logger.debug/1 instead"
  def debug(message), do: Logger.debug(message)

  @doc """
  Log Information.
  """
  @deprecated "Use LambdaBase.Logger.info/1 instead"
  def info(message), do: Logger.info(message)

  @doc """
  Log Warning.
  """
  @deprecated "Use LambdaBase.Logger.warn/1 instead"
  def warn(message), do: Logger.warn(message)

  @doc """
  Log Error.
  """
  @deprecated "Use LambdaBase.Logger.error/1 instead"
  def error(message), do: Logger.error(message)
end