defmodule TkDecoder.MixProject do
  use Mix.Project

  def project do
    [
      app: :tkdecoder,
      version: "0.1.0",
      elixir: "~> 1.9",
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end
end
