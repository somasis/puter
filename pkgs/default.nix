{
  sources ? import ../npins,

  system ? (builtins.currentSystem or null),

  nixpkgs ? sources.nixpkgs,

  pkgs ? (
    import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    }
  ),
  lib ? pkgs.lib,
  ...
}:
lib.filesystem.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage newScope;
  directory = ./.;
}
