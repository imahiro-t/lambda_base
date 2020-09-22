# LambdaBase

Base library to create Elixir AWS Lambda

## Installation

The package can be installed by adding `lambda_base` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lambda_base, "~> 1.2.0"}
  ]
end
```

If you run Lambda as application, you must add below.

```elixir
def project do
  [
    boot_mode: :app,
    custom_runtime: :amazon_linux2
  ]
end

def application do
  [
    mod: {LambdaBase.Application, []}
  ]
end
```

If you run Lambda on Amazon Linux 2, you must add below.

```elixir
def project do
  [
    custom_runtime: :amazon_linux2
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

amazon linux
```
$ docker run -d -it --rm --name elx erintheblack/elixir-lambda-builder:1.10.0
$ docker cp ${project} elx:/tmp
$ docker exec elx /bin/bash -c "cd /tmp/${project}; mix deps.get; MIX_ENV=prod mix lambda.release"
$ docker cp elx:/tmp/${app_name}-${version}.zip .
```

amazon linux2
```
$ docker run -d -it --rm --name elx erintheblack/elixir-lambda-builder:al2_1.10.4
$ docker cp ${project} elx:/tmp
$ docker exec elx /bin/bash -c "cd /tmp/${project}; mix deps.get; MIX_ENV=prod mix lambda.release"
$ docker cp elx:/tmp/${app_name}-${version}.zip .
```

3. Upload zip file and set configuration.
- Set `Module Name` to `handler`.
- Set Log level to `environment` -> `LOG_LEVEL`
  - `debug`, `info`, `warn`, `error`

The docs can be found at [https://hexdocs.pm/lambda_base](https://hexdocs.pm/lambda_base).

