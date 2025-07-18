defmodule Excon.MixProject do
  use Mix.Project

  def project do
    [
      app: :excon,
      version: "4.1.0",
      elixir: "~> 1.15",
      name: "excon",
      source_url: "https://github.com/mwmiller/excon",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      xref: [exclude: [Blake2, :png]]
    ]
  end

  def application do
    [extra_applications: [:png, :blake2]]
  end

  defp deps do
    [
      {:png, "~> 0.2"},
      {:blake2, "~> 1.0"},
      {:ex_doc, "~> 0.38", only: :dev}
    ]
  end

  defp description do
    """
    PNG/SVG identicons in pure Elixir.
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
