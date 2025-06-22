defmodule Excon.ImageMaker do
  @moduledoc """
    Behaviour for creating images from a hash.
  """
  @callback create_image(hash :: binary, magnification :: integer) :: binary
end
