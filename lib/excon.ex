defmodule Excon do

  @palettes {
    {:rgb, 8, [{0,153, 153}, {64, 179, 179}, {127, 204, 204}, {191, 229, 229}]},
    {:rgb, 8, [{0, 152, 102}, {64, 178, 140}, {127, 203, 178}, {191, 229, 217}]},
    {:rgb, 8, [{101, 44, 143}, {140, 97, 171}, {178, 149, 199}, {216, 202, 227}]},
    {:rgb, 8, [{255, 204, 51}, {255, 217, 102}, {255, 229, 153}, {255, 242, 204}]},
    {:rgb, 8, [{153, 153, 0}, {179, 179, 64}, {204, 204, 127}, {229, 229, 191}]},
    {:rgb, 8, [{102, 152, 0}, {140, 178, 64}, {178, 203, 127}, {217, 229, 191}]},
    {:rgb, 8, [{143, 44, 101}, {171, 97, 140}, {199, 149, 178}, {227, 202, 216}]},
    {:rgb, 8, [{51, 204, 255}, {102, 217, 255}, {153, 229, 255}, {204, 242, 255}]},
    {:rgb, 8, [{102, 0, 152}, {140, 64, 178}, {178, 127, 203}, {217, 191, 229}]},
    {:rgb, 8, [{255, 51, 204}, {255, 102, 217}, {255, 153, 229}, {255, 204, 242}]},
    {:rgb, 8, [{44, 101, 143}, {97, 140, 171}, {149, 178, 199}, {202, 216, 227}]},
    {:rgb, 8, [{153, 0, 153}, {179, 64, 179}, {204, 127, 204}, {229, 191, 229}]},
  }

  defp mirror(thing, dir), do: do_mirror(thing, dir, [])
  defp do_mirror([], _, acc), do: acc |> Enum.reverse
  defp do_mirror([r|rows], :ltr, acc) do
    do_mirror(rows, :ltr, [r |> Enum.concat(r |> Enum.reverse) | acc])
  end
  defp do_mirror([r|rows], :rtl, acc) do
    do_mirror(rows, :rtl, [(r|> Enum.reverse) |> Enum.concat(r) | acc])
  end
  defp do_mirror(rows, :ttb, _), do: rows |> Enum.concat(Enum.reverse(rows))
  defp do_mirror(rows, :btt, _), do: Enum.reverse(rows) |> Enum.concat(rows)

  defp hashtopat(str), do: do_hashtopat(str, [])
  defp do_hashtopat(<<>>, acc), do: acc |> Enum.reverse |> Enum.chunk(4)
  defp do_hashtopat(<<t::integer-size(2),rest::bitstring>>, acc), do: do_hashtopat(rest,[t|acc])

  defp magnify(thing, how_much) do
    thing |> expand_cols(how_much, [])
          |> expand_rows(how_much, [])
  end

  defp expand_cols([], _n, acc), do: acc |> Enum.reverse
  defp expand_cols([r|rest], n, acc), do: expand_cols(rest,n,[expand_col(r,n,[])|acc])
  defp expand_col([], _n, acc), do: acc |> List.flatten |> Enum.reverse
  defp expand_col([c|rest], n, acc), do: expand_col(rest, n, [List.duplicate(c,n)|acc])

  defp expand_rows([], _n, acc), do: acc
  defp expand_rows([r|rest], n, acc), do: expand_rows(rest, n, Enum.concat(acc,expand_row(r, n, [])))
  defp expand_row(_i, 0, acc), do: acc
  defp expand_row(i, n, acc), do: expand_row(i, n-1, [i|acc])

  defp to_png(pattern, filename, mag, pal) do
    {:ok, outfile} = File.open(filename<>".png", [:write])
   %{size: {8*mag,8*mag},
     mode: {:indexed,8},
     file: outfile,
     palette: pal}  |> :png.create
                    |> png_append_pattern(pattern |> magnify(mag))
                    |> :png.close
   File.close(outfile)
  end

  defp png_append_pattern(png, []), do: png
  defp png_append_pattern(png, [r|rest]) do
    png |> :png.append({:row, :binary.list_to_bin(r)})
        |> png_append_pattern(rest)
  end

  defp parse_options(options) do
    { Keyword.get(options, :filename, "identicon"),
      Keyword.get(options, :magnification, 8),
      Keyword.get(options, :type, :png),
    }
  end

  @doc """
  Create an indenticon from an identifying string.

  Options
    - `type`: :png or :svg  (default: :png)
    - `filename`: a string for the file name (default: "identicon")
    - `magnification`: how many times to magnify the 8x8 pattern (default: 4)
  """
  def ident(id, opts \\ []) do
    {fname, mag, type} = parse_options(opts)
    hash = Blake2.hash2b(id,5)
    case type do
      :png -> ident_png(hash, fname, mag)
      :svg -> ident_svg(hash, fname, mag)
      _    -> {:error, "Unknown file type"}
    end
  end

  defp ident_png(hash, fname, mag) do
    <<forpat::binary-size(4), forpal::integer-size(8)>> = hash

    forpat
        |> hashtopat
        |> mirror(:ltr)
        |> mirror(:ttb)
        |> to_png(fname, mag, @palettes |> elem(rem(forpal,12)))

  end

  defp ident_svg(hash, fname, mag) do
    File.write(fname<>".svg", svg_contents(hash,mag))
  end

  defp svg_contents(hash, mag) do
    <<
      b1o::integer-size(4),  b2o::integer-size(4),  b3o::integer-size(4),  b4o::integer-size(4),
      b1e::integer-size(2),  b2e::integer-size(2),  b3e::integer-size(2),  b4e::integer-size(2),
      b1ci::integer-size(4), b2ci::integer-size(4), b3ci::integer-size(4), b4ci::integer-size(4)
    >> = hash
    [b1c,b2c,b3c,b4c] = Enum.map([b1ci, b2ci, b3ci, b4ci], fn n -> @palettes |> elem(n |> rem(12)) |> elem(2) end)
    stroke =  "stroke=\"rgba(191,191,191}, 1.0)\""
    """
    <svg width="#{8*mag}" height="#{8*mag}" version="1.1"
         xmlns="http://www.w3.org/2000/svg">
        <path d="M#{8*mag},#{8*mag} L0,#{4*mag} L0,#{8*mag} L#{8*mag},#{8*mag}" #{svg_fill(b1c,b1e,b1o)} #{stroke} />
        <path d="M0,#{8*mag} L#{8*mag},#{4*mag} L#{8*mag},#{8*mag} L0,#{8*mag}" #{svg_fill(b2c,b2e,b2o)} #{stroke} />
        <path d="M0,0 L#{8*mag},#{4*mag} L#{8*mag},0 L0,0" #{svg_fill(b3c,b3e,b3o)} #{stroke} />
        <path d="M#{8*mag},0 L0,#{4*mag} L0,0 L#{8*mag},0" #{svg_fill(b4c,b4e,b4o)} #{stroke} />
    </svg>
    """
  end

  defp svg_fill(pal,w,o) do
   octets =  pal |> Enum.fetch!(w) |> Tuple.to_list |> Enum.join(",")
   "fill=\"rgba(#{octets},#{o/32})\""
  end

end
