defmodule Excon.ImageMaker.PNG do
  @behaviour Excon.ImageMaker
  @moduledoc """
  The PNG interface for ExCon.
  """

  alias Excon.PNGUtils
  def create_image(hash, mag)

  def create_image(<<forpat::binary-size(4), forpal::bitstring-size(4), _unused::size(4)>>, mag) do
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
