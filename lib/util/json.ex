defmodule Util.Json do
  @moduledoc """
  JSON parser.
  """

  @doc """
  Generates JSON corresponding to `input`.

  ## Examples

      iex> Util.Json.encode(%{"key" => "value"})
      "{\\"key\\":\\"value\\"}"

  """
  @spec encode(term()) :: String.t() | no_return()
  def encode(input), do: Jason.encode!(input)

  @doc """
  Parses a JSON value from `input` iodata.

  ## Examples

      iex> Util.Json.decode("{\\"key\\":\\"b\\"}")
      %{"key" => "value"}

  """
  @spec decode(iodata()) :: term() | no_return()
  def decode(input), do: Jason.decode!(input)
end