# Used by ./default.nix, provided at `overlay`.
final: prev:
prev.lib.recursiveUpdate prev (
  import ./pkgs {
    inherit (prev) lib;
    pkgs = prev;
  }
)
