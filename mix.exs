defmodule Cony.MixProject do
  use Mix.Project

  def project do
    [
      app: :cony,
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod
    ]
  end

  def application, do: []
end
