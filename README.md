# Excon

Identicons from Elixir.

## Installation

  1. Add `excon` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:excon, "~> 4.0"}]
    end
    ```

## Output 

### PNG

iex> Excon.ident("Excon", filename: "Excon64", magnification: 8)

![PNG](Excon64.png?raw=true "ExCon Identicon")

iex> Excon.ident("Excon", base64: true, magnification: 8)

"iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAMAAACdt4HsAAAADFBMVEX/gCH/qRT1xaH00rjuVoX9AAAAAklEQVR4nGKkkSsAAABfSURBVO3UKQ4AMQxD0S73v/OQJMCS2ZBa36yV80qirlvZlT4fiestgAjADW6JgwAyAB3UgntgFgkgAujMYlSuxPUAAABygC48/KUB/AC4ggLuAYAMQC8UcoOzSAAJwAe+BR0BwZDwWwAAAABJRU5ErkJggg=="
