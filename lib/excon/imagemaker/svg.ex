defmodule Excon.ImageMaker.SVG do
  @behaviour Excon.ImageMaker
  @moduledoc """
  The :svg interface for ExCon.

  With background circles and an abstract path, these look a bit like Slack identicons.
  """

  alias Excon.Palettes

  def create_image(hash, mag) do
    <<cpo::integer-size(4), cpe::integer-size(4), fp::integer-size(2), c1::bitstring-size(6),
      c2::bitstring-size(6), c3::bitstring-size(6), c4::bitstring-size(6),
      fc::bitstring-size(6)>> = hash

    odds = Palettes.get(cpo)
    evens = Palettes.get(cpe)
    fg = Palettes.get(fp)

    img = """
    <svg width="#{8 * mag}" height="#{8 * mag}" version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{8 * mag} #{8 * mag}">
    #{do_circle(2, 2, 2, c1, mag, odds)}
    #{do_circle(2, 6, 2, c2, mag, evens)}
    #{do_circle(6, 6, 2, c3, mag, odds)}
    #{do_circle(6, 2, 2, c4, mag, evens)}
    #{do_path(fc, mag, fg)}
    </svg>
    """

    {"svg", img}
  end

  defp do_circle(x, y, r, c, mag, pal),
    do: "<circle cx=\"#{x * mag}\" cy=\"#{y * mag}\" r=\"#{r * mag}\" #{fill(c, pal)}/>"

  defp do_path(
         <<ys::integer-size(1), yf::integer-size(1), x1::integer-size(1), y1::integer-size(1),
           x2::integer-size(1), y2::integer-size(1)>> = c,
         mag,
         pal
       ),
       do:
         "<path d=\"M0,#{(ys * 4 + 4) * mag}  C#{x1 * 8 * mag},#{y1 * -2 * mag} #{x2 * -2 * mag},#{y2 * 8 * mag} #{8 * mag},#{(yf * 4 + 4) * mag}\" #{fill(c, pal, 0.375)}/>"

  defp fill(<<w::integer-size(2), o::integer-size(4)>>, pal, opbase \\ 0.5) do
    "fill=\"rgba(#{pal |> Enum.fetch!(w) |> Tuple.to_list() |> Enum.join(",")},#{opbase + o / 32}\""
  end
end
