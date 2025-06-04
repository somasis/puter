{ pkgs ? import <nixpkgs> { }
,
}:
let
  inherit (pkgs) callPackage;
in
{
  pass-botp = callPackage ./pass-botp { };
  pass-link = callPackage ./pass-link { };
  pass-meta = callPackage ./pass-meta { };
}
