defmodule ExBitstamp.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_bitstamp,
      version: "0.1.0",
      description: "Elixir client library for Bitstamp HTTP API",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExBitstamp",
      source_url: "https://github.com/mvrkljan/ex_bitstamp",
      docs: [
        main: "ExBitstamp"
        # logo: "path/to/logo.png"
      ],
      package: [
        licenses: ["MIT"],
        files: ["lib", "mix.exs", "README*"],
        maintainers: ["Martin Vrkljan"],
        links: %{"GitHub" => "https://github.com/mvrkljan/ex_bitstamp"}
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/mocks"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExBitstamp.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.18.2"},
      {:mock, "~> 0.3.1", only: :test}
    ]
  end
end
