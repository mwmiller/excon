defmodule Excon.ImageMaker.PNG do
  @behaviour Excon.ImageMaker
  @moduledoc """
  The :png interface for ExCon.

  With left-to-right and top-to-bottom symmetry and a four color palette,
  these look a bit like 8-bit graphics.
  """

  alias Excon.PNGUtils
  def create_image(hash, mag)

  def create_image(<<forpat::binary-size(4), forpal::integer-size(4), _unused::size(4)>>, mag) do
    img =
      forpat
      |> hashtopat
      |> PNGUtils.mirror(:ltr)
      |> PNGUtils.mirror(:ttb)
      |> PNGUtils.pattern_to_png(mag, forpal)

    {"png", img}
  end

  defp hashtopat(str), do: do_hashtopat(str, [])
  defp do_hashtopat(<<>>, acc), do: acc |> Enum.reverse() |> Enum.chunk_every(4)

  defp do_hashtopat(<<t::integer-size(2), rest::bitstring>>, acc),
    do: do_hashtopat(rest, [t | acc])
end
