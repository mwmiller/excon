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
    hash = Blake2.hash2b(id,6)
    case type do
      :png -> ident_png(hash, fname, mag)
      :svg -> ident_svg(hash, fname, mag)
      _    -> {:error, "Unknown file type"}
    end
  end

  defp ident_png(hash, fname, mag) do
    <<forpat::binary-size(4), forpal::integer-size(16)>> = hash

    forpat
        |> hashtopat
        |> mirror(:ltr)
        |> mirror(:ttb)
        |> to_png(fname, mag, @palettes |> elem(rem(forpal,8)))

  end

  defp ident_svg(hash, fname, mag) do
    File.write(fname<>".svg", svg_contents(hash,mag))
  end

  defp svg_contents(hash, mag) do
    <<t1x::integer-size(3), t1y::integer-size(3),
      t2x::integer-size(3), t2y::integer-size(3),
      m1x::integer-size(3), m1y::integer-size(3),
      m2x::integer-size(3), m2y::integer-size(3),
      b1x::integer-size(3), b1y::integer-size(3),
      b2x::integer-size(3), b2y::integer-size(3),
      tci::integer-size(3), mci::integer-size(3), bci::integer-size(3),
      pali::integer-size(2), stk::integer-size(1)
     >> = hash
    [tc,mc,bc] = Enum.map([tci, mci, bci], fn n -> @palettes |> elem(n) |> elem(2) end)
    stroke = svg_stroke(stk)
    """
    <svg width="#{8*mag}" height="#{8*mag}" version="1.1"
         xmlns="http://www.w3.org/2000/svg">
        <path d="M0,0 C#{t1x*mag},#{t1y*mag} #{t2x*mag},#{t2y*mag} #{8*mag},#{8*mag}" #{svg_fill(tc,pali)} #{stroke} />
        <path d="M0,#{8*mag} C#{b1x*mag},#{b1y*mag} #{b2x*mag},#{b2y*mag} #{8*mag},0"  #{svg_fill(mc,pali)} #{stroke} />
        <path d="M0,#{4*mag} C#{m1x*mag},#{m1y*mag} #{m2x*mag},#{m2y*mag} #{8*mag},#{4*mag}"   #{svg_fill(bc,pali)} #{stroke} />
    </svg>
    """
  end

  defp svg_stroke(stk) do
    "stroke=\"rgba(#{if stk, do: "191,191,191", else: "64,64,64"}, 1.0)\""
  end

  defp svg_fill(pal,w) do
   octets =  pal |> Enum.fetch!(w) |> Tuple.to_list |> Enum.join(",")
   "fill=\"rgba(#{octets},0.50)\""
  end

end
