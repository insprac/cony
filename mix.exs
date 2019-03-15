defmodule Cony.MixProject do
  use Mix.Project

  def project do
    [
      app: :cony,
      version: "0.2.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/insprac/cony",
      name: "Cony"
    ]
  end

  def application, do: []

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
    ]
  end

  def description do
    "Define configurations using environment variables."
  end

  def package do
    [
      name: "cony",
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/insprac/cony"}
    ]
  end
end
