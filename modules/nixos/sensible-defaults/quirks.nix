{
  self,
  config,
  lib,
  nixpkgs,
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
    # (fetchpatch {
    #   url = "https://github.com/NixOS/nixpkgs/pull/387720.patch";
    #   hash = "sha256-dPu/9KNaB1mAcYIiVMAZ8tFdCX9YjuutuL0qKAJ1uj0=";
    # })

    # Added 2025-10-09: fix failing trurl tests
    (fetchpatch2 {
      url = "https://github.com/NixOS/nixpkgs/pull/450487.patch";
      hash = "sha256-QubgzWD/YdMbBEVpXN0uLVk1B/J4ZwK357lCuiv2sh8=";
    })

    # Added 2025-10-23: fix libquotient and NeoChat build
    (fetchpatch2 {
      url = "https://github.com/NixOS/nixpkgs/pull/455083.patch";
      hash = "sha256-jb/KYkYC2/a/WKeU1OlbW7ulxWp5YYFKlSFmn+NCvf4=";
    })

    # Added 2025-10-23: fix pcsx2
    (fetchpatch2 {
      url = "https://github.com/NixOS/nixpkgs/pull/454958.patch";
      hash = "sha256-O1/4ae4w2bq5d6rQQf8zjEreyYF5k/iLRv8x2+xbcZc=";
    })
  ];

  # deadnix: skip
  nixpkgs-quirks =
    if patches != [ ] then
      let
        args = {
          inherit (pkgs) config;
          inherit (pkgs.stdenvNoCC) system hostPlatform;
        };
      in
      import ((import nixpkgs args).applyPatches {
        name = "nixpkgs-quirks";
        src = nixpkgs;
        inherit patches;
      }) args
    else
      nixpkgs;

  overlay = final: prev: {
    # Continuing the earlier example, make sure to do an override
    # for the patched package too.
    # inherit (nixpkgs-quirks.pkgs) cantata;
    inherit (nixpkgs-quirks.pkgs)
      pcsx2
      trurl
      ;

    kdePackages = prev.kdePackages // {
      inherit (nixpkgs-quirks.pkgs.kdePackages) libquotient neochat;
    };
  };
in
{
  # Fix issues with poorly rendered fonts that can occur
  # when running Qt 6 applications on Wayland.
  # Issue first showed up in qutebrowser <https://github.com/qutebrowser/qutebrowser/discussions/7938>
  # but it can happen in other applications, like KDE's systemsettings.
  # Necessary as of 2025-03-13 NixOS 24.11.
  environment.sessionVariables.QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";

  nixpkgs = {
    overlays = [ overlay ];
    config.permittedInsecurePackages = [ "olm-3.2.16" ];
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
