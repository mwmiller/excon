defmodule Excon.Mixfile do
  use Mix.Project

  def project do
    [app: :excon,
     version: "2.0.0",
     elixir: "~> 1.4",
     name: "excon",
     source_url: "https://github.com/mwmiller/excon",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    []
  end

  defp deps do
  [
    {:png, "~> 0.1"},
    {:blake2, "~> 1.0"},
    {:earmark, "~> 1.0", only: :dev},
    {:ex_doc, "~> 0.14", only: :dev},
  ]
  end

  defp description do
    """
    excon - pure Elixir identicons
    """
  end

  defp package do
    [
     files: ["lib", "mix.exs", "README*", "LICENSE*", ],
     maintainers: ["Matt Miller"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mwmiller/excon",
             }
    ]
  end
end
