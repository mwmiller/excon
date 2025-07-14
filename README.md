# Excon

Identicons in Elixir.

## Installation

Add `excon` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:excon, "~> 4.0"}]
    end
    ```

## Output

### PNG

iex> Excon.ident("excon", filename: "excon64", magnification: 8)

![PNG](excon64.png?raw=true "excon Identicon")

iex> Excon.ident("excon", filename: "excon32", magnification: 4, type: :duotone)

![PNG](excon32.png?raw=true "excon Identicon")

### SVG
iex> Excon.ident("excon", filename: "excon64", magnification: 8, type: :svg)

![SVG](excon64.svg?raw=true "excon Identicon")

iex> Excon.ident("excon", filename: "excon32", magnification: 4, type: :framed)

![SVG](excon32.svg?raw=true "excon Identicon")
