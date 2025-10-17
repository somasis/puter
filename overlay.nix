# Used by ./default.nix, provided at `overlay`.
final: prev:
prev.lib.recursiveUpdate prev (import ./pkgs { pkgs = final; })
