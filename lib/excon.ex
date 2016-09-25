defmodule Excon do

  @palettes {
    {:rgb, 8, [{136, 51, 0}, {255, 187, 119}, {255, 255, 187}, {255, 221, 136}]}, # Earthy
    {:rgb, 8, [{105, 210, 231}, {167, 219, 216}, {224, 228, 204}, {250, 105, 0}]}, # Mayan
    {:rgb, 8, [{28, 70, 107}, {187, 220, 195}, {111, 144, 181}, {105, 24, 146}]}, # Reef
    {:rgb, 8, [{3, 112, 114}, {248, 222, 118}, {67, 239, 156}, {22, 201, 168}]}, # Bright
  }

  def mirror(thing, dir), do: do_mirror(thing, dir, [])
  def do_mirror([], _, acc), do: acc |> Enum.reverse
  def do_mirror([r|rows], :ltr, acc) do
    do_mirror(rows, :ltr, [r |> Enum.concat(r |> Enum.reverse) | acc])
  end
  def do_mirror([r|rows], :rtl, acc) do
    do_mirror(rows, :rtl, [(r|> Enum.reverse) |> Enum.concat(r) | acc])
  end
  def do_mirror(rows, :ttb, _), do: rows |> Enum.concat(Enum.reverse(rows))
  def do_mirror(rows, :btt, _), do: Enum.reverse(rows) |> Enum.concat(rows)

  def hashtopat(str), do: do_hashtopat(str, [])
  def do_hashtopat(<<>>, acc), do: acc |> Enum.reverse |> Enum.chunk(4)
  def do_hashtopat(<<t::integer-size(2),rest::bitstring>>, acc), do: do_hashtopat(rest,[t|acc])

  def magnify(thing, how_much) do
    thing |> expand_cols(how_much, [])
          |> expand_rows(how_much, [])
  end

  def expand_cols([], _n, acc), do: acc |> Enum.reverse
  def expand_cols([r|rest], n, acc), do: expand_cols(rest,n,[expand_col(r,n,[])|acc])
  def expand_col([], _n, acc), do: acc |> List.flatten |> Enum.reverse
  def expand_col([c|rest], n, acc), do: expand_col(rest, n, [List.duplicate(c,n)|acc])

  def expand_rows([], _n, acc), do: acc
  def expand_rows([r|rest], n, acc), do: expand_rows(rest, n, Enum.concat(acc,expand_row(r, n, [])))
  def expand_row(_i, 0, acc), do: acc
  def expand_row(i, n, acc), do: expand_row(i, n-1, [i|acc])

  def to_png(pattern, filename, mag, pal) do
    {:ok, outfile} = File.open(filename<>".png", [:write])
   %{size: {8*mag,8*mag},
     mode: {:indexed,8},
     file: outfile,
     palette: pal}  |> :png.create
                    |> png_append_pattern(pattern |> magnify(mag))
                    |> :png.close
   File.close(outfile)
  end

  def png_append_pattern(png, []), do: png
  def png_append_pattern(png, [r|rest]) do
    png |> :png.append({:row, :binary.list_to_bin(r)})
        |> png_append_pattern(rest)
  end

  defp parse_options(options) do
    { Keyword.get(options, :filename, "identicon"),
      Keyword.get(options, :magnification, 4)
    }
  end

  def ident(id,opts \\ []) do
    {fname, mag} = parse_options(opts)
    <<forpat::binary-size(4), forpal::integer-size(8)>> = id  |> Blake2.hash2b(5)

    forpat
        |> hashtopat
        |> mirror(:ltr)
        |> mirror(:ttb)
        |> to_png(fname, mag, @palettes |> elem(rem(forpal,4)))
  end

end
