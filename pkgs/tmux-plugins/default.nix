{ pkgs ? import <nixpkgs> { }
,
}:
let
  inherit (pkgs) callPackage;
in
{
  aw-watcher-tmux = callPackage ./aw-watcher-tmux { };
}
