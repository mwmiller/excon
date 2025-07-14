defmodule Excon.ImageMaker.Duotone do
  @behaviour Excon.ImageMaker
  @moduledoc """
  The :duotone interface for ExCon.

  With left--to-right symmetry and a two color palette these
  PNGs look a bit like GitHub identicons.
  """

  alias Excon.PNGUtils
  def create_image(hash, mag)

  def create_image(
        <<forpat::binary-size(4), fi::integer-size(2), si::integer-size(2),
          forpal::integer-size(4)>>,
        mag
      ) do
    # We have to reduce the entropy a bit because some of these palettes
    # do not have enough contrast with only 2 colors
    pal =
      case forpal do
        3 -> 1
        14 -> 4
        12 -> 6
        15 -> 10
        _ -> forpal
      end

    img =
      forpat
      |> hashtopat(fi, si)
      |> PNGUtils.mirror(:ltr)
      |> PNGUtils.pattern_to_png(mag, pal)

    {"png", img}
  end

  defp hashtopat(string, first_index, first_index) do
    # They are both the same color, so we move the second index.
    second_index =
      case first_index do
        0 -> 3
        1 -> 0
        2 -> 1
        3 -> 2
      end

    hashtopat(string, first_index, second_index)
  end

  defp hashtopat(string, first_index, second_index) do
    do_hashtopat(string, first_index, second_index, [])
  end

  defp do_hashtopat(<<>>, _, _, acc), do: acc |> Enum.reverse() |> Enum.chunk_every(4)

  defp do_hashtopat(<<0::size(1), rest::bitstring>>, fi, si, acc),
    do: do_hashtopat(rest, fi, si, [fi | acc])

  defp do_hashtopat(<<1::size(1), rest::bitstring>>, fi, si, acc),
    do: do_hashtopat(rest, fi, si, [si | acc])
end
