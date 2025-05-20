{ pkgs ? import <nixpkgs> { }
,
}:
let
  inherit (pkgs) callPackage;
in
{
  pass-link = callPackage ./pass-link { };
  pass-meta = callPackage ./pass-meta { };
}
