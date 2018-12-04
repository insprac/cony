defmodule Cony.MixProject do
  use Mix.Project

  def project do
    [
      app: :cony,
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/insprac/cony"
    ]
  end

  def application, do: []

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
