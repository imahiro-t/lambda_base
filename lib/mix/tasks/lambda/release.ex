defmodule Mix.Tasks.Lambda.Release do
  @moduledoc """
  Create zip file for AWS Lamdba with custom runtime.

  Run this task inside Docker image `amazonlinux:2017.03.1.20170812`.

  Docker image `erintheblack/elixir-lambda-builder:20200112.01` is prepared to build.

  ## How to build

  ```
  $ docker run -d -it --name elx erintheblack/elixir-lambda-builder:20200112.01
  $ docker cp ${project} elx:/tmp
  $ docker exec elx /bin/bash -c "cd /tmp/${project}; mix deps.get; mix lambda.release"
  $ docker cp elx:/tmp/${app_name}.zip .
  ```

  ## Lambda setting

  - Set `Module Name` to `handler`.
  - Set Log level to `environment` -> `LOG_LEVEL`
  """

  use Mix.Task

  @doc """
  Create zip file for AWS Lamdba with custom runtime.
  """
  @impl Mix.Task
  def run(_args) do
    app_name = app_name()
    bootstrap = bootstrap(app_name)
    Mix.env(:prod)
    Mix.Shell.cmd("rm -f -R ./_build/prod/*", &IO.puts/1)
    Mix.Task.run("release")
    File.write("./_build/prod/rel/#{app_name}/bootstrap", bootstrap)
    Mix.Shell.cmd("chmod +x ./_build/prod/rel/#{app_name}/bin/#{app_name}", &IO.puts/1)
    Mix.Shell.cmd("chmod +x ./_build/prod/rel/#{app_name}/releases/*/elixir", &IO.puts/1)
    Mix.Shell.cmd("chmod +x ./_build/prod/rel/#{app_name}/erts-*/bin/erl", &IO.puts/1)
    Mix.Shell.cmd("chmod +x ./_build/prod/rel/#{app_name}/bootstrap", &IO.puts/1)
    Mix.Shell.cmd("cd ./_build/prod/rel/#{app_name}; zip #{app_name} -r -q *", &IO.puts/1)
    Mix.Shell.cmd("mv -f ./_build/prod/rel/#{app_name}/#{app_name}.zip ../", &IO.puts/1)
  end

  defp app_name do
    Mix.Project.config |> Keyword.get(:app) |> to_string
  end

  defp bootstrap(app_name) do
    """
#!/bin/sh

set -euo pipefail
export HOME=/
RESPONSE=$(bin/#{app_name} eval "$(echo "$_HANDLER").start()")
"""
  end
end