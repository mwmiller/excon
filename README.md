# Excon

Identicons from Elixir.

## Installation

  1. Add `excon` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:excon, "~> 0.1"}]
    end
    ```

## Output 

### PNG

iex> Excon.ident("ExCon", filename: "excon", magnification: 16)

![PNG](excon.png?raw=true "ExCon Ideniticon")

### SVG

iex> Excon.ident("ExCon", filename: "excon", type: :svg, magnification: 16)

![SVG](excon.svg?raw=true "ExCon Identicon")
