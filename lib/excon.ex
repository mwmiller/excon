defmodule Excon do
  @moduledoc """
  Pure Elixir identicon creator

  This module dispatches to the appropriate image format based on the options provided.
  """

  @doc """
  Create an indenticon from an identifying string.

  Options
    - `type`: :png or :svg  (default: :png)
    - `filename`: a string for the file name (default: nil, image data is returned)
    - `magnification`: how many times to magnify the 8x8 pattern (default: 4)
    - `base64`: should output be base64 encoded (default: false, filename overrides)

  ## Examples

      iex> Excon.ident("ExCon", base64: true)
      "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAADFBMVEXwwNjmqNT62dn/0tL9+OiNAAAAAklEQVR4nGKkkSsAAABBSURBVGNghAJmIGCCAhAbJs5ABwUwDkiCAQpAbJgmeiiAM4AA7jAggGmklwKYJCygkMVGkoKBjovBkiZhnAHKmwBcxQWBMC75hwAAAABJRU5ErkJggg=="

      iex> Excon.ident("excon", magnification: 8, filename: "excon64")
      :ok
  """
  @default_options [filename: nil, magnification: 4, type: :png, base64: false]
  def ident(id, opts \\ []) do
    o = Keyword.merge(@default_options, opts)

    handler = Module.safe_concat([Excon, ImageMaker, String.capitalize(Atom.to_string(o[:type]))])

    id
    |> Blake2.hash2b(5)
    |> handler.create_image(o[:magnification])
    |> output(o[:filename], o[:base64])
  end

  defp output({_ext, img}, nil, true), do: img |> Base.encode64()
  defp output({_ext, img}, nil, false), do: img
  defp output({ext, img}, filename, _b64), do: :ok = File.write("#{filename}.#{ext}", img)
end
