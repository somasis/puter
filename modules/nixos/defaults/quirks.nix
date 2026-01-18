{
  self,
  config,
  lib,
  pkgs,
  ...
}:
# Quirks and workarounds for issues.
# Ideally these can be removed on system upgrades, so try and
# remove things if they don't appear necessary anymore.

# Leave dead code in here so that sometimes no quirks are needed,
# without deadnix wanting to change this file.
let
  # deadnix: skip
  inherit (pkgs) fetchpatch2;
  patches = [
    # Here's an example:
    # # Added 2025-04-17: switch to maintained fork of Cantata
    # (fetchpatch2 {
    #   url = "https://github.com/NixOS/nixpkgs/pull/387720.patch";
    #   hash = "sha256-dPu/9KNaB1mAcYIiVMAZ8tFdCX9YjuutuL0qKAJ1uj0=";
    # })
  ];

  # deadnix: skip
  nixpkgs-quirks =
    let
      args = {
        inherit (pkgs) config;
        inherit (pkgs.stdenvNoCC) hostPlatform;
      };
    in
    if patches != [ ] then
      import ((import pkgs.path args).applyPatches {
        name = "nixpkgs-quirks";
        src = pkgs.path;
        inherit patches;
      }) args
    else
      import pkgs.path args;

  overlay = final: prev: {
    # Continuing the earlier example, make sure to do an override
    # for the patched package too.
    # inherit (nixpkgs-quirks) cantata;
  };
in
{
  nixpkgs = {
    overlays = [ overlay ];
    config.permittedInsecurePackages = [
      # Used by various Matrix clients (in my case, NeoChat).
      "olm-3.2.16"
    ];
  };

  home-manager.sharedModules = [
    (lib.optionalAttrs (!config.home-manager.useGlobalPkgs) (
      { osConfig, ... }:
      {
        nixpkgs = {
          overlays = [ overlay ];
          config.permittedInsecurePackages = osConfig.nixpkgs.config.permittedInsecurePackages;
        };
      }
    ))
  ];
}
