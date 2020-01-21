defmodule LambdaBase do
  @moduledoc """
  This is lambda base.
  Use LambdaBase and implement `handle(event, context)` function
  """

  alias Util.Json
  alias Util.LambdaLogger

  @doc """
  Lambda runtime call handle function.
  """
  @callback handle(event :: map(), context :: map()) :: {:ok, String.t} | {:error, String.t}

  defmacro __using__(_opts) do
    quote do
      alias Util.Json
      alias Util.LambdaLogger
      @behaviour LambdaBase
      def start() do
        LambdaBase.start(__MODULE__)
      end
    end
  end

  def start(module) do
    context = System.get_env
    LambdaLogger.start(context |> log_level)
    HTTPoison.start()
    loop(context, module)
  end

  defp log_level(context) do
    context |> Map.get("LOG_LEVEL", "INFO") |> String.downcase |> String.to_atom
  end

  defp loop(context, module) do
    endpoint_uri = context |> next_uri
    case HTTPoison.get(endpoint_uri) do
      {:error, error} ->
        {:error, error.reason}
      {:ok, response} ->
        {_, request_id} = response.headers |> Enum.find(fn {x, _} -> x == "Lambda-Runtime-Aws-Request-Id" end)
        handle_event(response.body |> Json.decode, context, request_id, module)
    end
    loop(context, module)
  end

  defp handle_event(event, context, request_id, module) do
    LambdaLogger.debug(event)
    LambdaLogger.debug(context)
    LambdaLogger.debug(request_id)
    try do
      case apply(module, :handle, [event, context]) do
        {:ok, result} ->
          LambdaLogger.debug(result)
          endpoint_uri = context |> response_uri(request_id)
          HTTPoison.post(endpoint_uri, result)
        {:error, error} ->
          LambdaLogger.error(error)
          endpoint_uri = context |> error_uri(request_id)
          HTTPoison.post(endpoint_uri, error |> error_message |> Json.encode)
      end
    rescue
      exception ->
        LambdaLogger.error(exception)
        endpoint_uri = context |> error_uri(request_id)
        HTTPoison.post(endpoint_uri, exception |> exception_message |> Json.encode)
    end
  end

  defp next_uri(context) do
    aws_lambda_runtime_api = context |> Map.get("AWS_LAMBDA_RUNTIME_API")
    "http://#{aws_lambda_runtime_api}/2018-06-01/runtime/invocation/next"
  end

  defp response_uri(context, request_id) do
    aws_lambda_runtime_api = context |> Map.get("AWS_LAMBDA_RUNTIME_API")
    "http://#{aws_lambda_runtime_api}/2018-06-01/runtime/invocation/#{request_id}/response"
  end

  defp error_uri(context, request_id) do
    aws_lambda_runtime_api = context |> Map.get("AWS_LAMBDA_RUNTIME_API")
    "http://#{aws_lambda_runtime_api}/2018-06-01/runtime/invocation/#{request_id}/error"
  end

  defp error_message(error) do
    %{
      errorMessage: error,
      errorType: "Error"
    }
  end

  defp exception_message(error) do
    %{
      errorMessage: error,
      errorType: "Exception"
    }
  end
end
