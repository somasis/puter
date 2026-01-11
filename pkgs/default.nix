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
(lib.removeAttrs
  (lib.filesystem.packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage newScope;
    directory = ./.;
  })
  [
    "build-support"
    "default"
    "packages"
  ]
)
// (lib.listToAttrs (
  map (x: {
    name = lib.removeSuffix ".nix" (baseNameOf x);
    value = pkgs.callPackage x;
  }) (lib.filesystem.listFilesRecursive ./build-support)
))
