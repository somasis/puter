{ pkgs ? import <nixpkgs> { }
,
}:
let
  inherit (pkgs) callPackage;
in
{
  click-kak = callPackage ./click-kak { };
  csv-kak = callPackage ./csv-kak { };
  kakoune-fcitx = callPackage ./kakoune-fcitx { };
  kakoune-find = callPackage ./kakoune-find { };
  kakoune-filetree = callPackage ./kakoune-filetree { };
  tug = callPackage ./tug { };
}
