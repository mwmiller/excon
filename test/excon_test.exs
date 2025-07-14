defmodule ExconTest do
  use ExUnit.Case
  doctest Excon

  @s "testdata"

  test "png" do
    std =
      <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 32, 0, 0, 0, 32, 8,
        3, 0, 0, 0, 68, 164, 138, 198, 0, 0, 0, 12, 80, 76, 84, 69, 0, 152, 102, 64, 178, 140,
        127, 203, 178, 191, 229, 217, 78, 253, 53, 208, 0, 0, 0, 2, 73, 68, 65, 84, 120, 156, 98,
        164, 145, 43, 0, 0, 0, 63, 73, 68, 65, 84, 99, 96, 4, 2, 102, 40, 96, 128, 2, 24, 31, 36,
        199, 64, 7, 5, 48, 9, 70, 52, 0, 83, 72, 15, 5, 48, 14, 19, 16, 192, 36, 65, 108, 152, 38,
        122, 40, 128, 49, 96, 1, 131, 204, 134, 5, 220, 72, 80, 48, 24, 226, 98, 176, 164, 201, 1,
        206, 155, 0, 216, 182, 5, 65, 220, 23, 212, 189, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96,
        130>>

    assert Excon.ident(@s) == std

    tiny =
      <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 8, 0, 0, 0, 8, 8,
        3, 0, 0, 0, 243, 209, 78, 185, 0, 0, 0, 12, 80, 76, 84, 69, 0, 152, 102, 64, 178, 140,
        127, 203, 178, 191, 229, 217, 78, 253, 53, 208, 0, 0, 0, 2, 73, 68, 65, 84, 120, 156, 98,
        164, 145, 43, 0, 0, 0, 39, 73, 68, 65, 84, 69, 139, 129, 9, 0, 48, 12, 194, 146, 250, 255,
        207, 115, 48, 86, 17, 34, 168, 152, 64, 34, 193, 234, 130, 209, 41, 48, 214, 108, 248,
        213, 142, 223, 253, 0, 12, 24, 0, 85, 172, 158, 193, 20, 0, 0, 0, 0, 73, 69, 78, 68, 174,
        66, 96, 130>>

    assert Excon.ident(@s, type: :png, magnification: 1) == tiny
  end

  test "svg" do
    std =
      "<svg width=\"32\" height=\"32\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 32 32\">\n<circle cx=\"8\" cy=\"8\" r=\"8\" fill=\"rgba(51,204,255,0.65625\"/>\n<circle cx=\"8\" cy=\"24\" r=\"8\" fill=\"rgba(255,169,20,0.5625\"/>\n<circle cx=\"24\" cy=\"24\" r=\"8\" fill=\"rgba(102,217,255,0.53125\"/>\n<circle cx=\"24\" cy=\"8\" r=\"8\" fill=\"rgba(244,210,184,0.625\"/>\n<path d=\"M0,16  C32,-8 -8,32 32,32\" fill=\"rgba(255,217,102,0.84375\"/>\n</svg>\n"

    assert Excon.ident(@s, type: :svg) == std

    big =
      "<svg width=\"64\" height=\"64\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 64 64\">\n<circle cx=\"16\" cy=\"16\" r=\"16\" fill=\"rgba(51,204,255,0.65625\"/>\n<circle cx=\"16\" cy=\"48\" r=\"16\" fill=\"rgba(255,169,20,0.5625\"/>\n<circle cx=\"48\" cy=\"48\" r=\"16\" fill=\"rgba(102,217,255,0.53125\"/>\n<circle cx=\"48\" cy=\"16\" r=\"16\" fill=\"rgba(244,210,184,0.625\"/>\n<path d=\"M0,32  C64,-16 -16,64 64,64\" fill=\"rgba(255,217,102,0.84375\"/>\n</svg>\n"

    assert Excon.ident(@s, type: :svg, magnification: 8) == big
  end

  test "duotone" do
    std =
      "\x89PNG\r\n\x1A\n\0\0\0\rIHDR\0\0\0 \0\0\0 \b\x03\0\0\0D\xA4\x8A\xC6\0\0\0\fPLTE,e\x8Fa\x8C\xAB\x95\xB2\xC7\xCA\xD8\xE34\x93\xAE\x87\0\0\0\x02IDATx\x9Cb\xA4\x91+\0\0\0=IDATc`\0\x02F\x1C\x80\x01\x06h\xAC\0C5\x9A\xA6\x91\xA2\0\xC6A\x17\xC4\bI:)@w$\xBD\x14 K\xA2\a\x1A<$i\xAC\0\xDDa\xD8\x1CLk\x05\xE8\x11\x84\xC1\xA6\xBD\x02\0U\xDC\x02\x01r\x99\x85\x05\0\0\0\0IEND\xAEB`\x82"

    assert Excon.ident(@s, type: :duotone) == std

    tiny =
      "\x89PNG\r\n\x1A\n\0\0\0\rIHDR\0\0\0\b\0\0\0\b\b\x03\0\0\0\xF3\xD1N\xB9\0\0\0\fPLTE,e\x8Fa\x8C\xAB\x95\xB2\xC7\xCA\xD8\xE34\x93\xAE\x87\0\0\0\x02IDATx\x9Cb\xA4\x91+\0\0\0 IDATc``\x04\x03\x06\x06\x10\x06\x93p\x06\x03\x98\r\xE2AD \x88\x11\xC6ER\xCF\xC8\b\0\x04\xFE\0!\x99\x8F\xFE\xA3\0\0\0\0IEND\xAEB`\x82"

    assert Excon.ident(@s, type: :duotone, magnification: 1) == tiny
  end

  test "framed" do
    std =
      "<svg width=\"32\" height=\"32\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 32 32\">\n<rect width=\"100%\" height=\"100%\" fill=\"#BFE5D9\" stroke=\"#009866\" />\n<path d=\"M 12,8 28,0 4,12 24,20 4,16 0,28 28,28 20,12\" stroke=\"#7FCBB2\" stroke-width=\"1\" fill=\"#40B28C\" />\n\n</svg>\n"

    assert Excon.ident(@s, type: :framed) == std

    big =
      "<svg width=\"64\" height=\"64\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 64 64\">\n<rect width=\"100%\" height=\"100%\" fill=\"#BFE5D9\" stroke=\"#009866\" />\n<path d=\"M 24,16 56,0 8,24 48,40 8,32 0,56 56,56 40,24\" stroke=\"#7FCBB2\" stroke-width=\"1\" fill=\"#40B28C\" />\n\n</svg>\n"

    assert Excon.ident(@s, type: :framed, magnification: 8) == big
  end
end
