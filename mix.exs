defmodule Excon.Mixfile do
  use Mix.Project

  def project do
    [
      app: :excon,
      version: "4.0.0",
      elixir: "~> 1.7",
      name: "excon",
      source_url: "https://github.com/mwmiller/excon",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:png, "~> 0.1"},
      {:blake2, "~> 1.0"},
      {:ex_doc, "~> 0.23", only: :dev},
    ]
  end

  defp description do
    """
    excon - pure Elixir identicons
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Matt Miller"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mwmiller/excon"}
    ]
  end
end
