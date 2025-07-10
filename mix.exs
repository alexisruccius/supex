defmodule Supex.MixProject do
  use Mix.Project

  def project do
    [
      app: :supex,
      version: "0.1.1",
      description:
        "An Elixir wrapper for the music live-coding language SuperCollider. Supex communicates with SuperCollider’s `sclang` tool, letting you generate and control sound directly from Elixir.",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # ExDocs
      source_url: "https://github.com/alexisruccius/supex",
      homepage_url: "https://github.com/alexisruccius/supex",
      docs: docs(),
      # Hex
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  # ExDocs
  defp docs do
    [
      # The main page in the docs
      main: "Supex",
      logo: "assets/supex-logo.jpg",
      extras: ["README.md"]
    ]
  end

  # Hex package
  defp package do
    [
      maintainers: ["Alexis Ruccius"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/alexisruccius/supex"}
    ]
  end
end
