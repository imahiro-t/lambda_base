defmodule Mix.Tasks.Lambda.Release do
  @moduledoc """
  Create zip file for AWS Lamdba with custom runtime.

  Run this task inside Docker image `amazonlinux:2017.03.1.20170812`.

  Docker image `erintheblack/elixir-lambda-builder:20200112.01` is prepared to build.

  ## How to build

  ```
  $ docker run -d -it --rm --name elx erintheblack/elixir-lambda-builder:1.10.0
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
    boot_mode = boot_mode()
    bootstrap = bootstrap(app_name, boot_mode)
    env = Mix.env
    Mix.Shell.cmd("rm -f -R ./_build/#{env}/*", &IO.puts/1)
    Mix.Shell.cmd("MIX_ENV=#{env} mix release", &IO.puts/1)
    File.write("./_build/#{env}/rel/#{app_name}/bootstrap", bootstrap)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/bin/#{app_name}", &IO.puts/1)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/releases/*/elixir", &IO.puts/1)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/erts-*/bin/erl", &IO.puts/1)
    Mix.Shell.cmd("chmod +x ./_build/#{env}/rel/#{app_name}/bootstrap", &IO.puts/1)
    Mix.Shell.cmd("cd ./_build/#{env}/rel/#{app_name}; zip #{app_name}-#{version}.zip -r -q *", &IO.puts/1)
    Mix.Shell.cmd("mv -f ./_build/#{env}/rel/#{app_name}/#{app_name}-#{version}.zip ../", &IO.puts/1)
  end

  defp app_name do
    Mix.Project.config |> Keyword.get(:app) |> to_string
  end

  defp version do
    Mix.Project.config |> Keyword.get(:version)
  end

  defp boot_mode do
    Mix.Project.config |> Keyword.get(:boot_mode)
  end

  defp bootstrap(app_name, boot_mode) do
    boot_script = if (boot_mode == :app) do
      "$(bin/#{app_name} start)"
    else
      "$(bin/#{app_name} eval \"$(echo \"$_HANDLER\").start()\")"
    end
"""
#!/bin/sh

set -euo pipefail
export HOME=/
BOOT_MODE="${BOOT_MODE:-eval}"
RESPONSE=#{boot_script}
"""
  end
end
