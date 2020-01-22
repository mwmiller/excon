defmodule Excon do
  @moduledoc """
  Pure Elixir identicon creator
  """

  @palettes {
    [{0, 153, 153}, {64, 179, 179}, {127, 204, 204}, {191, 229, 229}],
    [{0, 152, 102}, {64, 178, 140}, {127, 203, 178}, {191, 229, 217}],
    [{101, 44, 143}, {140, 97, 171}, {178, 149, 199}, {216, 202, 227}],
    [{255, 204, 51}, {255, 217, 102}, {255, 229, 153}, {255, 242, 204}],
    [{153, 153, 0}, {179, 179, 64}, {204, 204, 127}, {229, 229, 191}],
    [{102, 152, 0}, {140, 178, 64}, {178, 203, 127}, {217, 229, 191}],
    [{143, 44, 101}, {171, 97, 140}, {199, 149, 178}, {227, 202, 216}],
    [{51, 204, 255}, {102, 217, 255}, {153, 229, 255}, {204, 242, 255}],
    [{102, 0, 152}, {140, 64, 178}, {178, 127, 203}, {217, 191, 229}],
    [{255, 51, 204}, {255, 102, 217}, {255, 153, 229}, {255, 204, 242}],
    [{44, 101, 143}, {97, 140, 171}, {149, 178, 199}, {202, 216, 227}],
    [{153, 0, 153}, {179, 64, 179}, {204, 127, 204}, {229, 191, 229}],
    [{255, 128, 33}, {255, 169, 20}, {245, 197, 161}, {244, 210, 184}],
    [{250, 200, 250}, {220, 80, 220}, {230, 150, 230}, {240, 100, 240}],
    [{240, 192, 216}, {230, 168, 212}, {250, 217, 217}, {255, 210, 210}],
    [{112, 220, 113}, {183, 240, 183}, {152, 218, 150}, {218, 255, 222}]
  }

  defp mirror(thing, dir), do: do_mirror(thing, dir, [])
  defp do_mirror([], _, acc), do: acc |> Enum.reverse()

  defp do_mirror([r | rows], :ltr, acc),
    do: do_mirror(rows, :ltr, [r |> Enum.concat(r |> Enum.reverse()) | acc])

  defp do_mirror([r | rows], :rtl, acc),
    do: do_mirror(rows, :rtl, [r |> Enum.reverse() |> Enum.concat(r) | acc])

  defp do_mirror(rows, :ttb, _), do: rows |> Enum.concat(Enum.reverse(rows))
  defp do_mirror(rows, :btt, _), do: rows |> Enum.reverse() |> Enum.concat(rows)

  defp hashtopat(str), do: do_hashtopat(str, [])
  defp do_hashtopat(<<>>, acc), do: acc |> Enum.reverse() |> Enum.chunk_every(4)

  defp do_hashtopat(<<t::integer-size(2), rest::bitstring>>, acc),
    do: do_hashtopat(rest, [t | acc])

  defp magnify(thing, how_much) do
    thing
    |> expand_cols(how_much, [])
    |> expand_rows(how_much, [])
  end

  defp expand_cols([], _n, acc), do: acc |> Enum.reverse()
  defp expand_cols([r | rest], n, acc), do: expand_cols(rest, n, [expand_col(r, n, []) | acc])
  defp expand_col([], _n, acc), do: acc |> List.flatten() |> Enum.reverse()
  defp expand_col([c | rest], n, acc), do: expand_col(rest, n, [List.duplicate(c, n) | acc])

  defp expand_rows([], _n, acc), do: acc

  defp expand_rows([r | rest], n, acc),
    do: expand_rows(rest, n, Enum.concat(acc, expand_row(r, n, [])))

  defp expand_row(_i, 0, acc), do: acc
  defp expand_row(i, n, acc), do: expand_row(i, n - 1, [i | acc])

  defp to_png(pattern, mag, pdx) do
    {:ok, pid} = Agent.start(fn -> [] end)

    %{
      size: {8 * mag, 8 * mag},
      mode: {:indexed, 8},
      call: fn i -> Agent.update(pid, fn state -> [i | state] end) end,
      palette: computed_pal(pdx)
    }
    |> :png.create()
    |> png_append_pattern(pattern |> magnify(mag))
    |> :png.close()

    img_data = Agent.get(pid, fn state -> state end)
    Agent.stop(pid)

    img_data
    |> List.flatten()
    |> Enum.reverse()
    |> Enum.join()
  end

  defp computed_pal(<<pi::integer-size(4), _unused::integer-size(4)>>) do
    {:rgb, 8, @palettes |> elem(pi)}
  end

  defp png_append_pattern(png, []), do: png

  defp png_append_pattern(png, [r | rest]) do
    png
    |> :png.append({:row, :binary.list_to_bin(r)})
    |> png_append_pattern(rest)
  end

  defp parse_options(options) do
    {Keyword.get(options, :filename, nil), Keyword.get(options, :magnification, 4),
     Keyword.get(options, :type, :png), Keyword.get(options, :base64, false)}
  end

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
  iex> Excon.ident("ExCon", filename: "excon")
  :ok
  """
  def ident(id, opts \\ []) do
    {fname, mag, type, b64} = parse_options(opts)

    id
    |> Blake2.hash2b(5)
    |> ident(type, mag)
    |> output(fname, type, b64)
  end

  defp output(img, nil, _t, true), do: img |> Base.encode64()
  defp output(img, nil, _t, false), do: img

  defp output(img, filename, type, _b64),
    do: :ok = File.write(filename <> "." <> Atom.to_string(type), img)

  defp ident(<<forpat::binary-size(4), forpal::bitstring-size(8)>>, :png, mag) do
    forpat
    |> hashtopat
    |> mirror(:ltr)
    |> mirror(:ttb)
    |> to_png(mag, forpal)
  end

  defp ident(hash, :svg, mag) do
    <<cpo::integer-size(4), cpe::integer-size(4), fp::integer-size(2), c1::bitstring-size(6),
      c2::bitstring-size(6), c3::bitstring-size(6), c4::bitstring-size(6),
      fc::bitstring-size(6)>> = hash

    odds = elem(@palettes, cpo)
    evens = elem(@palettes, cpe)
    fg = elem(@palettes, fp)

    """
    <svg width="#{8 * mag}" height="#{8 * mag}" version="1.1" xmlns="http://www.w3.org/2000/svg">
    #{do_circle(2, 2, 2, c1, mag, odds)}
    #{do_circle(2, 6, 2, c2, mag, evens)}
    #{do_circle(6, 6, 2, c3, mag, odds)}
    #{do_circle(6, 2, 2, c4, mag, evens)}
    #{do_path(fc, mag, fg)}
    </svg>
    """
  end

  defp do_circle(x, y, r, c, mag, pal),
    do: "<circle cx=\"#{x * mag}\" cy=\"#{y * mag}\" r=\"#{r * mag}\" #{svg_fill(c, pal)}/>"

  defp do_path(
         <<ys::integer-size(1), yf::integer-size(1), x1::integer-size(1), y1::integer-size(1),
           x2::integer-size(1), y2::integer-size(1)>> = c,
         mag,
         pal
       ),
       do:
         "<path d=\"M0,#{(ys * 4 + 4) * mag}  C#{x1 * 8 * mag},#{y1 * -2 * mag} #{x2 * -2 * mag},#{
           y2 * 8 * mag
         } #{8 * mag},#{(yf * 4 + 4) * mag}\" #{svg_fill(c, pal, 0.375)}/>"

  defp svg_fill(<<w::integer-size(2), o::integer-size(4)>>, pal, opbase \\ 0.5) do
    "fill=\"rgba(#{pal |> Enum.fetch!(w) |> Tuple.to_list() |> Enum.join(",")},#{opbase + o / 32}\""
  end
end
