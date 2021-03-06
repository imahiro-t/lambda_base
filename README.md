# LambdaBase

Base library to create Elixir AWS Lambda

## Installation

The package can be installed by adding `lambda_base` to your list of dependencies in `mix.exs`:

```elixir
def application do
  [
    mod: {LambdaBase.Application, []}
  ]
end

def deps do
  [
    {:lambda_base, "~> 1.3.4"}
  ]
end
```

## Basic Usage

1. Create Lambda module. Implement handle(event, context) function.

```elixir
defmodule UpCase do
  use LambdaBase
  @impl LambdaBase
  def init(context) do
    # call back one time
    {:ok, context}
  end
  @impl LambdaBase
  def handle(event, context) do
    {:ok, event |> Json.encode |> String.upcase}
  end
end
```

2. Create zip file for AWS Lambda.

```
$ docker run -d -it --rm --name elx erintheblack/elixir-lambda-builder:al2_1.10.4
$ docker cp mix.exs elx:/tmp
$ docker cp lib elx:/tmp
$ docker exec elx /bin/bash -c "mix deps.get; MIX_ENV=prod mix lambda.release"
$ docker cp elx:/tmp/${app_name}-${version}.zip .
$ docker stop elx
```

3. Upload zip file and set configuration.
- Set `Module Name` to `handler`.
- Set Log level to `environment` -> `LOG_LEVEL`
  - `debug`, `info`, `warn`, `error`

The docs can be found at [https://hexdocs.pm/lambda_base](https://hexdocs.pm/lambda_base).

