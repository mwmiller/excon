defmodule Excon do

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

  def ident(str) do
    str |> Blake2.hash2b(4)
        |> hashtopat
        |> mirror(:ltr)
        |> mirror(:ttb)
  end

end
