defmodule Excon.ImageMaker.FRAMESVG do
  @behaviour Excon.ImageMaker
  @moduledoc """
  The :framesvg interface for ExCon.

  With a four-color palette and a permuted path these look a bit
  like framed abstract art.
  """

  alias Excon.Palettes

  def create_image(hash, mag) do
    <<tlc::bitstring-size(4), dlc::bitstring-size(4), trc::bitstring-size(4),
      drc::bitstring-size(4), mlc::bitstring-size(4), mrc::bitstring-size(4),
      blc::bitstring-size(4), brc::bitstring-size(4), pal::integer-size(4), crot::size(2),
      permu::size(2)>> = hash

    colors = colors(pal, crot)

    coords =
      Enum.zip_reduce(
        [
          [tlc, dlc, trc, drc, mlc, mrc, blc, brc],
          [
            :top_left,
            :down_left,
            :top_right,
            :down_right,
            :mid_left,
            :mid_right,
            :bottom_left,
            :bottom_right
          ]
        ],
        %{},
        fn [coord, label], acc ->
          Map.put(acc, label, coords(coord, label))
        end
      )

    img =
      """
      <svg width="#{8 * mag}" height="#{8 * mag}" version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{8 * mag} #{8 * mag}">
      <rect width="100%" height="100%" fill="#{colors.bg}" stroke="#{colors.ol}" />
      #{do_path(permutation(coords, permu), mag, colors.il, colors.fg)}
      </svg>
      """

    {"svg", img}
  end

  defp colors(pali, crot) do
    pali
    |> Palettes.get()
    |> rotate(crot)
    |> then(fn pal ->
      Enum.zip([pal, [:bg, :ol, :fg, :il]])
    end)
    |> Enum.reduce(%{}, fn {color_tuple, key}, acc ->
      Map.put(acc, key, tuple_to_hex(color_tuple))
    end)
  end

  defp rotate(pal, 0), do: pal

  defp rotate(pal, crot) do
    [first | rest] = pal
    rotate(rest ++ [first], crot - 1)
  end

  defp tuple_to_hex({r, g, b}) do
    "##{hex_string(r)}#{hex_string(g)}#{hex_string(b)}"
  end

  defp hex_string(val) when is_integer(val) do
    val |> Integer.to_string(16) |> String.pad_leading(2, "0")
  end

  defp do_path(coords, mag, lc, fc) do
    path_data =
      Enum.map(coords, fn {x, y} -> "#{x * mag},#{y * mag}" end) |> Enum.join(" ")

    """
    <path d="M #{path_data}" stroke="#{lc}" stroke-width="1" fill="#{fc}" />
    """
  end

  defp coords(<<x::size(2), y::size(2)>>, :top_left), do: {x, y}
  defp coords(<<x::size(2), y::size(2)>>, :down_left), do: {x, y + 2}
  defp coords(<<x::size(2), y::size(2)>>, :mid_left), do: {x, cc(y + 4)}
  defp coords(<<x::size(2), y::size(2)>>, :bottom_left), do: {x, cc(y + 6)}
  defp coords(<<x::size(2), y::size(2)>>, :top_right), do: {x + 4, y}
  defp coords(<<x::size(2), y::size(2)>>, :down_right), do: {x + 4, cc(y + 2)}
  defp coords(<<x::size(2), y::size(2)>>, :mid_right), do: {x + 4, cc(y + 4)}
  defp coords(<<x::size(2), y::size(2)>>, :bottom_right), do: {x + 4, cc(y + 6)}

  defp cc(val), do: val |> abs |> rem(8)

  # We only provide 4 permutations chosen to "look different" enough
  @permutations {
    [
      :top_left,
      :top_right,
      :down_right,
      :down_left,
      :mid_left,
      :mid_right,
      :bottom_right,
      :bottom_left
    ],
    [
      :top_left,
      :down_left,
      :mid_left,
      :bottom_left,
      :bottom_right,
      :mid_right,
      :down_right,
      :top_right
    ],
    [
      :mid_left,
      :mid_right,
      :top_right,
      :top_left,
      :down_left,
      :down_right,
      :bottom_left,
      :bottom_right
    ],
    [
      :down_right,
      :bottom_right,
      :bottom_left,
      :mid_left,
      :mid_right,
      :top_left,
      :top_right,
      :down_left
    ]
  }
  defp permutation(coords, permu) do
    Enum.reduce(elem(@permutations, permu), [], fn key, acc -> [coords[key] | acc] end)
  end
end
