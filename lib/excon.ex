defmodule Excon do

  def mirror([], _, acc), do: acc |> Enum.reverse
  def mirror([r|rows], :ltr, acc) do
    mirror(rows, :ltr, [r |> Enum.concat(r |> Enum.reverse) | acc])
  end
  def mirror([r|rows], :rtl, acc) do
    mirror(rows, :rtl, [(r|> Enum.reverse) |> Enum.concat(r) | acc])
  end
  def mirror(rows, :ttb, _), do: rows |> Enum.concat(Enum.reverse(rows))
  def mirror(rows, :btt, _), do: Enum.reverse(rows) |> Enum.concat(rows)

end
