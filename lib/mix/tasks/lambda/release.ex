defmodule Mix.Tasks.Lambda.Release do
  @moduledoc """
  Create zip file for AWS Lamdba with custom runtime.

  Run this task inside Docker image `amazonlinux:2.0.20200722.0`.

  Docker image `erintheblack/elixir-lambda-builder:al2_1.10.4` is prepared to build.

  ## How to build

  ```
  $ docker run -d -it --rm --name elx erintheblack/elixir-lambda-builder:al2_1.10.4
  $ docker cp ${project} elx:/tmp
  $ docker exec elx /bin/bash -c "cd /tmp/${project}; mix deps.get; MIX_ENV=prod mix lambda.release"
  $ docker cp elx:/tmp/${app_name}-${version}.zip .
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
    version = version()
    custom_runtime = custom_runtime()
    bootstrap = bootstrap(app_name)
    env = Mix.env
    Mix.Shell.cmd("rm -f -R ./_build/#{env}/*", &IO.puts/1)
    Mix.Shell.cmd("MIX_ENV=#{env} mix release", &IO.puts/1)
    File.write("./_build/#{env}/rel/#{app_name}/bootstrap", bootstrap)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/bin/#{app_name}", &IO.puts/1)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/releases/*/elixir", &IO.puts/1)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/erts-*/bin/erl", &IO.puts/1)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/bootstrap", &IO.puts/1)
    if custom_runtime == :amazon_linux2 do
      Mix.Shell.cmd("cp -a /usr/lib64/libtinfo.so.6.0 ./_build/#{env}/rel/#{app_name}/lib/libtinfo.so.6", &IO.puts/1)
    end
    Mix.Shell.cmd("cd ./_build/#{env}/rel/#{app_name}; zip #{app_name}-#{version}.zip -r -q *", &IO.puts/1)
    Mix.Shell.cmd("mv -f ./_build/#{env}/rel/#{app_name}/#{app_name}-#{version}.zip ../", &IO.puts/1)
    Mix.Shell.cmd("cp -a ../#{app_name}-#{version}.zip ../#{app_name}.zip", &IO.puts/1)
  end

  defp app_name do
    Mix.Project.config |> Keyword.get(:app) |> to_string
  end

  defp version do
    Mix.Project.config |> Keyword.get(:version)
  end

  defp custom_runtime do
    Mix.Project.config |> Keyword.get(:custom_runtime)
  end

  defp bootstrap(app_name) do
"""
#!/bin/sh

set -euo pipefail
export HOME=/
$(bin/#{app_name} start)
"""
  end
end
