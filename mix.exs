defmodule LambdaBase.MixProject do
  use Mix.Project

  def project do
    [
      app: :lambda_base,
      version: "1.1.5",
      elixir: "~> 1.9",
      name: "LambdaBase",
      description: description(),
      package: package(),
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/imahiro-t/lambda_base",
      docs: [
        main: "readme", # The main page in the docs
        extras: ["README.md"]
      ]
    ]
  end

  defp description do
    "Base library to create Elixir AWS Lambda"
  end

  defp package do
    [ 
      maintainers: ["erin"],
      licenses: ["MIT"],
      links: %{ "Github" => "https://github.com/imahiro-t/lambda_base" }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:httpoison, "~> 1.6.2"},
      {:jason, "~> 1.1"}
    ]
  end
end
