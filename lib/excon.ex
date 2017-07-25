defmodule Excon do

  @palettes {
     [{0,153, 153}, {64, 179, 179}, {127, 204, 204}, {191, 229, 229}],
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
     [{255,128,33}, {255,169,20}, {245,197,161}, {244,210,184}],
     [{250,200,250}, {220,80,220}, {230,150,230}, {240,100,240}],
     [{240,192,216}, {230,168,212}, {250,217,217}, {255,210,210}],
     [{112,220,113}, {183,240,183}, {152,218,150}, {218,255,222}],
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

  defp to_png(pattern, filename, mag, pdx) do
    {:ok, outfile} = File.open(filename<>".png", [:write])
   %{size: {8*mag,8*mag},
     mode: {:indexed,8},
     file: outfile,
     palette: computed_pal(pdx) }
       |> :png.create
       |> png_append_pattern(pattern |> magnify(mag))
       |> :png.close
   File.close(outfile)
  end


  defp computed_pal(<<pi::integer-size(4), _unused::integer-size(4)>>) do
    {:rgb, 8, @palettes |> elem(pi)}
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
    <<forpat::binary-size(4), forpal::bitstring-size(8)>> = hash

    forpat
        |> hashtopat
        |> mirror(:ltr)
        |> mirror(:ttb)
        |> to_png(fname, mag, forpal)

  end

  defp ident_svg(hash, fname, mag) do
    File.write(fname<>".svg", svg_contents(hash,mag))
  end

  defp svg_contents(hash, mag) do
    <<
      c1::bitstring-size(9), c2::bitstring-size(9), c3::bitstring-size(9), c4::bitstring-size(9),
      gap::integer-size(2),  bgc::integer-size(2)
    >> = hash
    [s,m,e] = Enum.map([0,gap+1,8], fn n -> n * mag end);
    m1 = s + m
    m2 = e - m
    """
    <svg width="#{e}" height="#{e}" version="1.1"
         xmlns="http://www.w3.org/2000/svg">
        #{svg_bg(bgc,s,e)}
        <path d="M#{e},#{e} L#{s},#{m1} L#{s},#{e} L#{e},#{e}" #{svg_fill(c1)} />
        <path d="M#{s},#{e} L#{e},#{m1} L#{e},#{e} L#{s},#{e}" #{svg_fill(c2)} />
        <path d="M#{s},#{s} L#{e},#{m2} L#{e},#{s} L#{s},#{s}" #{svg_fill(c3)} />
        <path d="M#{e},#{s} L#{s},#{m2} L#{s},#{s} L#{e},#{s}" #{svg_fill(c4)} />
    </svg>
    """
  end

  defp svg_bg(c,s,e) do
    g = 127 + (c * 32)

    """
    <path d="M#{s},#{s} L#{s},#{e} L#{e},#{e} L#{e},#{s} L#{s},#{s}" fill="rgba(#{g},#{g},#{g},0.25)" />
    """
  end

  defp svg_fill(<<ci::integer-size(4),w::integer-size(2),o::integer-size(3)>>) do
    octets =  @palettes
               |> elem(ci)
               |> Enum.fetch!(w)
               |> Tuple.to_list
               |> Enum.join(",")
   "fill=\"rgba(#{octets},#{0.5+(o+1)/16}\""
  end

end
