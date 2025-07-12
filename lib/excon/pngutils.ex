defmodule Excon.PNGUtils do
  @moduledoc """
  Utility functions for ExCon PNG image processing.
  """
  alias Excon.Palettes

  @doc """
  Converts a pattern to a PNG image data string.
  The pattern is magnified by the given factor and uses the specified palette index.
  """
  def pattern_to_png(pattern, mag, pdx) do
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

  def mirror(thing, dir), do: do_mirror(thing, dir, [])
  defp do_mirror([], _, acc), do: acc |> Enum.reverse()

  defp do_mirror([r | rows], :ltr, acc),
    do: do_mirror(rows, :ltr, [r |> Enum.concat(r |> Enum.reverse()) | acc])

  defp do_mirror([r | rows], :rtl, acc),
    do: do_mirror(rows, :rtl, [r |> Enum.reverse() |> Enum.concat(r) | acc])

  defp do_mirror(rows, :ttb, _), do: rows |> Enum.concat(Enum.reverse(rows))
  defp do_mirror(rows, :btt, _), do: rows |> Enum.reverse() |> Enum.concat(rows)

  defp computed_pal(<<pi::integer-size(4), _rest::binary>>) do
    {:rgb, 8, Palettes.get(pi)}
  end

  defp png_append_pattern(png, []), do: png

  defp png_append_pattern(png, [r | rest]) do
    png
    |> :png.append({:row, :binary.list_to_bin(r)})
    |> png_append_pattern(rest)
  end
end
