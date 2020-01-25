defmodule LambdaBase.CommonBase do

  alias Util.Json
  alias Util.LambdaLogger

  @doc """
  Take log level from context.
  """
  def log_level(context) do
    context |> Map.get("LOG_LEVEL", "INFO") |> String.downcase |> String.to_atom
  end

  @doc """
  Loop and handle lambdas.
  """
  def loop(context) do
    endpoint_uri = context |> next_uri
    case HTTPoison.get(endpoint_uri) do
      {:error, error} ->
        {:error, error.reason}
      {:ok, response} ->
        {_, request_id} = response.headers |> Enum.find(fn {x, _} -> x == "Lambda-Runtime-Aws-Request-Id" end)
        event = try do
          response.body |> Json.decode
        rescue
          _ -> %{"data" => response.body}
        end
        handle_event(event, context, request_id)
    end
    loop(context)
  end

  defp handle_event(event, context, request_id) do
    LambdaLogger.debug(event)
    LambdaLogger.debug(context)
    LambdaLogger.debug(request_id)
    try do
      module = Module.concat([Elixir, context |> handler])
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

  defp handler(context) do
    context |> Map.get("_HANDLER")
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